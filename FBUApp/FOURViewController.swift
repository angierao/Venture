//
//  FOURViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 8/1/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MapKit
import FBSDKShareKit
import ParseFacebookUtilsV4
import AVKit
import AVFoundation

class FOURViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    var card: PFObject?
    var venue: Venue?
    var currLat: Double?
    var currLong: Double?
    var distance: String?
    var priceString: String?
    var savedString: String?
    var friendPics: [PFFile]?
    var reviews: [PFObject]?
    var venuePhotos: [String]?
    
    //Variables for computer vision stuff:
    var particularImage: UIImage?
    var pictureIndexes = [Int]()
    var cards: [PFObject]?
    var resultTuple = [(Int, Double, UIImage, Bool, [String], PFObject)]()
    var chosenPicResults : [String]?
    var plsImage:UIImage?
    var plsFile:PFFile?

    private lazy var client : ClarifaiClient = ClarifaiClient(appID: clarifaiClientID, appSecret: clarifaiClientSecret)

    
    @IBOutlet weak var recommendLabel: UILabel!
    @IBOutlet weak var similarPicturesCollectionView: UICollectionView!
    @IBOutlet weak var gradientView4: UIView!
    @IBOutlet weak var cardPicture: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recommendLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        let imageFile = card!["media"] as? PFFile
        imageFile?.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) in
            if imageData != nil {
                let cardImage = UIImage(data: imageData!)
                
                
                if self.card!["videoData"] != nil {
                    let imageToBlur = CIImage(image: cardImage!)
                    let blurfilter = CIFilter(name: "CIGaussianBlur")
                    blurfilter!.setValue(imageToBlur, forKey: "inputImage")
                    blurfilter!.setValue(30, forKey: "inputRadius")
                    let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
                    var blurredImage = UIImage(CIImage: resultImage)
                    var cropped:CIImage=resultImage.imageByCroppingToRect(CGRectMake(0, 0,imageToBlur!.extent.size.width, imageToBlur!.extent.size.height))
                    blurredImage = UIImage(CIImage: cropped)
                    self.cardPicture.image = blurredImage
                }
                else {
                    self.cardPicture.image = cardImage
                }
            }
        })

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = gradientView4.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        gradient.locations = [0.0, 0.58]

        
        gradientView4.layer.addSublayer(gradient)
        
        //Computer vision stuff
        
        similarPicturesCollectionView.delegate = self
        similarPicturesCollectionView.dataSource = self
        //Tag or dont tag if already tagged
        if(card!["tags"] != nil && (card!["tags"]).count > 0)
        {
            self.chosenPicResults = card!["tags"] as? [String]
            self.loadSimilarCards()
            
        }
        else
        {
            let cardImageFile = card!["media"]
            cardImageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
                if(error == nil)
                {
                    let dataImage = UIImage(data: data!)
                    self.recognizeImage(dataImage)
                }
                else{
                    print("Error getting the image from card")
                }
            })
        }

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureIndexes.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SimiCell", forIndexPath: indexPath) as! SimiCollCell
        let backImage = UIImage(named: "savedPlaceHolder")
        cell.similarPicImageView.image = backImage

        let sortedArrByIndex = resultTuple.sort({ $0.0 < $1.0 })
        let desiredIndex = (pictureIndexes[indexPath.row])
        var actualIndex = 0
        for s in 0 ..< sortedArrByIndex.count
        {
            if((sortedArrByIndex[s]).0 == desiredIndex)
            {
                actualIndex = s
            }
        }
        cell.similarPicImageView.image = (sortedArrByIndex[actualIndex]).2
        return cell

    }

    private func recognizeImage(image: UIImage!) {
        // Scale down the image. This step is optional. However, sending large images over the
        // network is slow and does not significantly improve recognition performance.
        let size = CGSizeMake(320, 320 * image.size.height / image.size.width)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Encode as a JPEG.
        let jpeg = UIImageJPEGRepresentation(scaledImage, 0.9)!
        
        // Send the JPEG to Clarifai for standard image tagging.
        client.recognizeJpegs([jpeg]) {
            (results: [ClarifaiResult]?, error: NSError?) in
            if error != nil {
                print("Error: \(error)\n")
            } else {
                let alltags = results![0].tags
                self.chosenPicResults = alltags
                var top8 = [String]()
                for i in 0 ..< 8
                {
                    top8.append(alltags[i])
                }
                self.chosenPicResults = top8
                self.card!["tags"] = self.chosenPicResults
                self.card?.saveInBackground()
                print("Top8 tags: \(self.chosenPicResults)")
            }
            self.loadSimilarCards()
        }
    }
    func loadSimilarCards()
    {
        //Get all the cards from the database
        let query = PFQuery(className: "Card")
        query.whereKeyDoesNotExist("videoUrl")
        query.findObjectsInBackgroundWithBlock { (cards: [PFObject]?, error: NSError?) in
            if cards == nil
            {
                print("Error \(error)")
            }
            else
            {
                self.cards = cards
                for (index,eachCard) in self.cards!.enumerate()
                {
                    //Send each card to the algorithm
                    let imageFile = eachCard["media"] as! PFFile
                    self.plsFile = imageFile
                    self.getDataFromPFFile(imageFile, index: index, eachCard: eachCard)
                }
            }
        }
    }
    func getDataFromPFFile(file: PFFile, index: Int, eachCard: PFObject) {
        
        file.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                let dataImage = UIImage(data:imageData!)
                self.plsImage = dataImage
                self.resultTuple.append((index, 0, dataImage!, false, [], eachCard))
                self.recognizeOthers(self.plsImage, index: index, eachCard: eachCard) //Returns an array of tags for the "other"
            }
            
        })
        
    }
    private func recognizeOthers(img: UIImage!, index: Int, eachCard: PFObject)
    {
        if(eachCard["tags"] != nil && (eachCard["tags"]).count > 0)
        {
            let top8Results = eachCard["tags"]
            let score = self.calculateScore(self.chosenPicResults!, tagsOther: top8Results as! [String], index: index)
            for i in 0 ..< resultTuple.count
            {
                if((resultTuple[i]).0 == index)
                {
                    (self.resultTuple[i]).4 = top8Results as! [String]
                    (self.resultTuple[i]).1 = score
                    (self.resultTuple[i]).3 = true
                    
                }
            }
            //If all the cards have been recognized:
            var allScore = true
            for tuple in self.resultTuple
            {
                if(tuple.3 == false)
                {
                    allScore = false
                    break;
                }
            }
            if(allScore)
            {
                self.returnTop()
            }
            
        }
        else
        {
            //var returnArr : [String]?
            let size = CGSizeMake(320, 320 * img.size.height / img.size.width)
            UIGraphicsBeginImageContext(size)
            img.drawInRect(CGRectMake(0, 0, size.width, size.height))
            let scaledimg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Encode as a JPEG.
            let jpeg = UIImageJPEGRepresentation(scaledimg, 0.9)!
            
            // Send the JPEG to Clarifai for standard image tagging.
            client.recognizeJpegs([jpeg])  {
                (results: [ClarifaiResult]?, error: NSError?) in
                if error != nil {
                    
                    print("Error: \(error)\n")
                    if(error!.code == 429)
                    {
                        self.alert("Throttled")
                    }
                } else {
                    var top8Results = [String]()
                    top8Results.removeAll()
                    let returnArrOthers = results![0].tags
                    for i in 0 ..< 8
                    {
                        top8Results.append(returnArrOthers[i])
                    }
                    eachCard["tags"] = top8Results
                    eachCard.saveInBackground()
                    let score = self.calculateScore(self.chosenPicResults!, tagsOther: top8Results, index: index)
                    for k in 0 ..< self.resultTuple.count
                    {
                        if((self.resultTuple[k]).0 == index)
                        {
                            (self.resultTuple[k]).1 = score
                            (self.resultTuple[k]).3 = true
                        }
                    }
                    //If all the cards have been recognized:
                    var allScore = true
                    for tuple in self.resultTuple
                    {
                        if(tuple.3 == false)
                        {
                            allScore = false
                        }
                    }
                    if(allScore == true)
                    {
                        self.returnTop()
                    }
                }
            }
            
        }
        
    }
    
    func calculateScore(tags: [String], tagsOther: [String], index: Int) -> Double
    {
        var count = 0
        for tag in tags
        {
            for tagOther in tagsOther
            {
                if tag == tagOther
                {
                    count += 1
                }
            }
        }
        return (Double(count) / 8)
    }
    func returnTop()
    {
        let sortedArr = resultTuple.sort({ $0.1 > $1.1 }) //SORT BY SCORE
        
        var indexArray = [Int]() //ARRAY OF THE INDEXES
        for thing in sortedArr
        {
            if(thing.1 > 0.3 && !doesAlreadyContains(indexArray, index: thing.0) && thing.1 != 1) //IF SCORE IS GOOD ENOUGH (But not the same image)
            {
                indexArray.append(thing.0)
            }
        }
        self.pictureIndexes = indexArray
        
        self.similarPicturesCollectionView.reloadData()
        
    }
    func doesAlreadyContains(arr: [Int], index: Int) -> Bool
    {
        for num in arr
        {
            if(num == index)
            {
                return true
            }
        }
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func alert (type: String) {
        if(type == "Throttled")
        {
            let alertController = UIAlertController(title: "Error", message: "Error fetching similar images, try again later.", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                
            }
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailToMoreDetailSegue" {
            let similarDetailVC = segue.destinationViewController as! SimilarDetailViewController
            let indexPath = similarPicturesCollectionView.indexPathForCell(sender as! UICollectionViewCell)
            let index = (self.pictureIndexes[indexPath!.row])
            var cardPFobj : PFObject?
            var image : UIImage?
            for(var i = 0; i < resultTuple.count; i+=1)
            {
                if((resultTuple[i]).0 == index)
                {
                    cardPFobj = (resultTuple[i]).5
                    image = (resultTuple[i]).2
                }
            }
            similarDetailVC.simCard = cardPFobj
            similarDetailVC.simImage = image
        }

    }

    

}
