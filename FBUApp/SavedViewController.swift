//
//  SavedViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/5/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse

class SavedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var viewOnMapButton: UIButton!
    
    var distanceString: String?
    var saved: [PFObject]?
    var savedKey: String = "savedCards"
    var savedDictionary =  [Int: UIImage]()
    
    var currLat : Double?
    var currLong: Double?
    var itemCount = 0
    var check = true
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = UIColor.blackColor()
        //self.view.backgroundColor = UIColor.clearColor()
        
        let user = PFUser.currentUser()
        saved = user![savedKey] as? [PFObject]
        var image = UIImage()
        
        /*for savedItem in saved! {
            //print("SAVED ITEM: \(savedItem)")
            /*savedItem.fetchIfNeededInBackgroundWithBlock { (save: PFObject?, error: NSError?) in
                if error != nil {
                    print(error)
                }
                else {

                    print("THE MEDIA: \(save!["media"])")
                    self.savedArray?.append(save!["media"] as! PFFile)
                    print("SAVED COUNT IN BACKGROUND: \(self.savedArray?.count)")
                    itemCount += 1
                }
            }*/
            
            let query = PFQuery(className: "Card")
            query.orderByDescending("createdAt")
            savedItem.fetchIfNeededInBackgroundWithBlock { (save: PFObject?, error: NSError?) in
                if error != nil {
                    print(error)
                }
                else {
                    query.whereKey("createdAt", equalTo: save!.createdAt!)
                    query.findObjectsInBackgroundWithBlock { (saves: [PFObject]?, error: NSError?) in
                        if error != nil {
                            print(error)
                        }
                        else {
                            let save = saves![0]
                            let imageFile = save["media"] as! PFFile
                            
                            imageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) in
                                if imageData != nil {
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                                        //load the image in the background
                                        image = UIImage(data: imageData!)!
                                        //image.CGImage // <- Force UIImage to not lazy load the data
                                        //when done, assign it to the cell's UIImageView
                                        //let newImage = self.resizeImage(image, newWidth: 300)
                                        self.savedDictionary[indexPath] = image
                                        self.itemCount += 1
                                        
                                        print("saved DICTIONARY COUNT: \(self.itemCount)")
                                        
                                        if self.savedDictionary.count == self.saved!.count {
                                            dispatch_async(dispatch_get_main_queue(), { 
                                                self.collectionView.reloadData()
                                            })
                                        }
                                    })
                                    /*image = UIImage(data: imageData!)!
                                     let newImage = self.resizeImage(image, newWidth: 100)
                                     cell.pictureView.image = image*/
                                   
                                    
                                }
                                else {
                                    print(error)
                                    
                                }
                            }
                            //self.collectionView.reloadData()
                            
                        }
                    }
                }
            }
            
        }*/
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        // Do any additional setup after loading the view, typically from a nib
        
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        //collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self

        viewOnMapButton.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
        savedLabel.font = UIFont (name: "HelveticaNeue-Thin", size: 25)
    }
    
    
    func cardForIndexPath(indexPath: NSIndexPath, cell: SavedCell) -> UIImage {
        var image = UIImage()
        //let save = saved![indexPath.row]
        let user = PFUser.currentUser()
        self.saved = user![savedKey] as? [PFObject]
        
        let indexNumber = Int(indexPath.row)
        let savedItem = saved![indexNumber] as? PFObject
        
        if self.savedDictionary[indexNumber] == nil {
            self.check = false
            //print("SAVED ITEM: \(savedItem)")
            /*savedItem.fetchIfNeededInBackgroundWithBlock { (save: PFObject?, error: NSError?) in
             if error != nil {
             print(error)
             }
             else {
             
             print("THE MEDIA: \(save!["media"])")
             self.savedArray?.append(save!["media"] as! PFFile)
             print("SAVED COUNT IN BACKGROUND: \(self.savedArray?.count)")
             itemCount += 1
             }
             }*/
            
            cell.pictureView.image = UIImage(named: "savedPlaceholder")
            savedItem!.fetchIfNeededInBackgroundWithBlock { (save: PFObject?, error: NSError?) in
                if error != nil {
                    print(error)
                }

                        else {
                            let imageFile = save!["media"] as! PFFile
                            
                            imageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) in
                                if imageData != nil {
                                        //load the image in the background
                                        image = UIImage(data: imageData!)!
                                        //image.CGImage // <- Force UIImage to not lazy load the data
                                        //when done, assign it to the cell's UIImageView
                                        //let newImage = self.resizeImage(image, newWidth: 300)
                                        self.savedDictionary[indexNumber] = image
                                        cell.pictureView.image = image
                                        self.itemCount += 1
                                        
                                        //print("saved DICTIONARY COUNT: \(self.itemCount)")
                                        
                                        if self.savedDictionary.count == self.saved!.count {
                                            dispatch_async(dispatch_get_main_queue(), {
                                                self.collectionView.reloadData()
                                            })
                                        }
                                    /*image = UIImage(data: imageData!)!
                                     let newImage = self.resizeImage(image, newWidth: 100)
                                     cell.pictureView.image = image*/
                                    
                                    
                                }
                                else {
                                    print(error)
                                    
                                }
                            }
                            //self.collectionView.reloadData()
                            
                        }
                    
                }
            }
        else {

            //cell.backgroundColor = UIColor.whiteColor()
            //cell.layer.borderColor = UIColor.blackColor().CGColor
            //cell.layer.borderWidth = 0.5
            //cell.frame.size.width = screenWidth / 3
            //cell.frame.size.height = screenWidth / 3
            cell.pictureView.image = self.savedDictionary[indexNumber]
            //cell.pictureView.frame = cell.frame
            
            return self.savedDictionary[indexNumber]!
        }
            
        
        
        

       
            if let pic = self.savedDictionary[indexNumber] {
                self.check = false
                //print("INDEX NUMBER: \(indexNumber)")
            /*pic.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) in
                if data != nil {
                    let image = UIImage(data: data!)
                    cell.pictureView.image = image
                    cell.pictureView.layer.cornerRadius = cell.pictureView.frame.height/2
                    cell.pictureView.clipsToBounds = true
                }*/
                
                //cell.pictureView.layer.cornerRadius = cell.pictureView.frame.height/2
                //cell.pictureView.clipsToBounds = true
            }
        
    
        
        //print(indexPath.row)
        /*let query = PFQuery(className: "Card")
        query.orderByDescending("createdAt")
        save.fetchIfNeededInBackgroundWithBlock { (save: PFObject?, error: NSError?) in
            if error != nil {
                print(error)
            }
            else {
                query.whereKey("createdAt", equalTo: save!.createdAt!)
                query.findObjectsInBackgroundWithBlock { (saves: [PFObject]?, error: NSError?) in
                    if error != nil {
                        print(error)
                    }
                    else {
                        let save = saves![0]
                        let imageFile = save["media"] as! PFFile
                        
                        imageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) in
                            if imageData != nil {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                                    //load the image in the background
                                    image = UIImage(data: imageData!)!
                                    image.CGImage // <- Force UIImage to not lazy load the data
                                    //when done, assign it to the cell's UIImageView
                                    let newImage = self.resizeImage(image, newWidth: 300)
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        cell.pictureView.image = newImage
                                        
                                    })
                                })
                                /*image = UIImage(data: imageData!)!
                                 let newImage = self.resizeImage(image, newWidth: 100)
                                 cell.pictureView.image = image*/
                            }
                            else {
                                print(error)
                                
                            }
                        }
                    }
                }
            }
        }*/
        
        return image
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return saved?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SavedCell", forIndexPath: indexPath) as! SavedCell
        cardForIndexPath(indexPath, cell: cell)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "infoSegue" {
            let detailVC = segue.destinationViewController as! ManagePageViewController
            let indexPath = collectionView.indexPathForCell(sender as! UICollectionViewCell)
            let card = saved![indexPath!.row]
            detailVC.card = card
            //let cardImageFile = card["media"]
            /*
            cardImageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
                if(error == nil)
                {
                    let dataImage = UIImage(data: data!)
                    detailVC.particularImage = dataImage
                }
            })*/
            detailVC.currLat = self.currLat
            detailVC.currLong = self.currLong
            detailVC.distance = self.distanceString
        }
        else if segue.identifier == "mapSegue" {
            let mapVC = segue.destinationViewController as! MapViewController
            mapVC.currLat = self.currLat
            mapVC.currLng = self.currLong
        }
        
    }
    

}
