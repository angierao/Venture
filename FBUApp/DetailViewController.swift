//
//  DetailViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/5/16.
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


class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var venueNameView: UIView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    private lazy var client : ClarifaiClient = ClarifaiClient(appID: clarifaiClientID, appSecret: clarifaiClientSecret)
    
    var url: String?
    var venue : Venue?
    var hours: NSDictionary?
    var photos: NSDictionary?
    var card: PFObject?
    var distance: String?
    var price: Int?
    var name: String?
    var tips: Double?
    var createdAt: NSDate?
    var address: NSArray?
    var distanceData: NSDictionary?
    var currLat : Double?
    var currLong: Double?
    let user = PFUser.currentUser()
    var cardLat: Double?
    var cardLong: Double?
    var venueId: String?
    var reviews: [PFObject]?
    var player: AVPlayer?
    var playButton: UIButton?

    var venuePhotos: [String]?
    
    var friendPics: [PFFile]?
    
    let imagePicker = UIImagePickerController()
    let button : FBSDKShareButton = FBSDKShareButton()
    
    var detailOriginalCenter: CGPoint!
    var detailUp: CGPoint!
    var detailDown: CGPoint!
    var detailDownOffset: CGFloat!
    
    @IBOutlet weak var fbShareButton: UIButton!

    @IBOutlet weak var writeAReviewButton: UIButton!
    @IBOutlet weak var reviewsButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var shareOnFBButton: UIButton!
    
    @IBOutlet weak var cardPicture: UIImageView!
    @IBOutlet weak var picsButton: UIButton!
    @IBOutlet weak var similarPicsCollectionView: UICollectionView!
    @IBOutlet weak var masterView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var estimatedPriceLabel: UILabel!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var whenSavedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var arrowView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
   
    @IBOutlet weak var mapView: MKMapView!
    
    //Variables for computer vision stuff:
    var particularImage: UIImage?
    var pictureIndexes = [Int]()
    var cards: [PFObject]?
    var resultTuple = [(Int, Double, UIImage, Bool, [String], PFObject)]()
    var chosenPicResults : [String]?
    var plsImage:UIImage?
    var plsFile:PFFile?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeFBShare()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fbShareButton.addTarget(self, action: #selector(DetailViewController.shareOnFBTapped(_:)), forControlEvents: .TouchUpInside)
        
        detailDownOffset = 205
        detailUp = CGPoint(x: detailView.center.x, y: detailView.center.y - detailDownOffset)
        
        detailDown = detailView.center
        detailView.clipsToBounds = true
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, scrollView.frame.height*2)
        
        scrollView.addSubview(masterView)
        friendPics = []
        venuePhotos = []
        detailView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        //venueNameView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        venueNameLabel.font = UIFont (name: "HelveticaNeue", size: 20)
        getVenueInfo()
        populateFriends()
        setButtons()       
        //shareOnFB()
        
        reviews = card!["reviews"] as? [PFObject]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        friendsCollectionView.delegate = self
        friendsCollectionView.dataSource = self
        
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        
        similarPicsCollectionView.delegate = self
        similarPicsCollectionView.dataSource = self
        
        populateLabels()
        initializeMapView()
        
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
        

        // Do any additional setup after loading the view.
    }
    func setButtons() {
        writeAReviewButton.layer.cornerRadius = writeAReviewButton.frame.height/2
        reviewsButton.layer.cornerRadius = writeAReviewButton.frame.height/2
        friendsButton.layer.cornerRadius = writeAReviewButton.frame.height/2
        picsButton.layer.cornerRadius = writeAReviewButton.frame.height/2
        shareOnFBButton.layer.cornerRadius = writeAReviewButton.frame.height/2
        fbShareButton.layer.cornerRadius = writeAReviewButton.frame.height/2
        shareOnFBButton.clipsToBounds = true
    }
    
    @IBAction func onWebsiteTap(sender: AnyObject) {
        if let url = NSURL(string: self.url!) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    @IBAction func writeAReviewTapped(sender: UIButton) {
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        handleButtonTapped(sender, viewIndex: -1)
    }
    
    
    @IBAction func reviewsTapped(sender: UIButton) {
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        handleButtonTapped(sender, viewIndex: 0)
    }
    
    
    @IBAction func friendsTapped(sender: UIButton) {
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        handleButtonTapped(sender, viewIndex: 1)
    }
    
    @IBAction func picsTapped(sender: UIButton) {
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        handleButtonTapped(sender, viewIndex: 2)
    }
    
    @IBAction func shareOnFBTapped(sender: UIButton) {
        button.sendActionsForControlEvents(.TouchUpInside)
        
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        handleButtonTapped(sender, viewIndex: -1)
    }
    
    func handleButtonTapped(tappedButton: UIButton, viewIndex: Int) {
        let buttons = [writeAReviewButton, reviewsButton, friendsButton, picsButton, shareOnFBButton]
        let views = [tableView, friendsCollectionView, photosCollectionView]
        for button in buttons {
            if button != tappedButton {
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else {
                button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            }
        }
        
        for (index, view) in views.enumerate() {
            if index == viewIndex {
                view.hidden = false
            }
            else {
                view.hidden = true
            }
        }
    }
    
   /* @IBAction func detailViewTapped(sender: UITapGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.Began {
            detailOriginalCenter = detailView.center
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            if self.detailView.center == self.detailUp {
                UIView.animateWithDuration(0.4, animations: {
                    self.detailView.center = self.detailDown
                    self.arrowView.image = UIImage(named: "uparrow")
                    self.venueNameLabel.alpha = 1
                    self.venueNameView.alpha = 1
                })
                
                
            }
            //else if self.detailView.center == self.detailDown {
            else {
                UIView.animateWithDuration(0.4, animations: {
                    self.detailView.center = self.detailUp
                    self.arrowView.image = UIImage(named: "downarrow")
                    self.venueNameLabel.alpha = 0
                    self.venueNameView.alpha = 0

                })
                
            }
        }
    }*/
    
    func populateFriends() {
        if(FBSDKAccessToken.currentAccessToken() != nil)
        {
            print(FBSDKAccessToken.currentAccessToken().hasGranted("user_friends"))
            if !FBSDKAccessToken.currentAccessToken().hasGranted("user_friends") {
                let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                loginManager.logInWithReadPermissions(["user_friends"], fromViewController: self, handler: { (response: FBSDKLoginManagerLoginResult!, error: NSError!) in
                    if error != nil {
                        print(error)
                    }
                })
            }
        }
        
        FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "name"], HTTPMethod: "GET").startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, response: AnyObject!, error: NSError!) in
            if response != nil {
                let dict = response as! NSDictionary
                let allFriends = dict.valueForKey("data") as! NSArray
                for friend in allFriends {
                    let dict = friend as! NSDictionary
                    let fbId = dict["id"] as! String
                    let query = PFUser.query()
                    query!.whereKey("fbId", containedIn: [fbId])
                    query!.findObjectsInBackgroundWithBlock({ (friends: [PFObject]?, error: NSError?) in
                        if friends != nil {
                            let friend = friends![0]
                            friend.fetchIfNeededInBackgroundWithBlock({ (friend: PFObject?, error: NSError?) in
                                if friend != nil {
                                    let saved = friend!["savedCards"] as! [PFObject]
                                    let objectId = self.card!.objectId
                                    for card in saved {
                                        if card.objectId == objectId {
                                            let imageFile = friend!["profileImage"] as! PFFile
                                            self.friendPics?.append(imageFile)
                                            break
                                            
                                        }
                                    }
                                    
                                
                                }
                                self.friendsCollectionView.reloadData()
                            })
                        
                        }
                        else {
                            print(error)
                        }
                    })
                }
            }
            else {
                print("error")
                print(error)
            }
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.friendsCollectionView {
            return self.friendPics?.count ?? 0
        }
        if collectionView == self.photosCollectionView {
            print("The VENU HAS: \(venuePhotos?.count)")
            return self.venuePhotos?.count ?? 0
        
        }
        if collectionView == self.similarPicsCollectionView {
            return pictureIndexes.count ?? 0
        }
        else {
            return 0
        }
    }
   
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == self.friendsCollectionView {
            let friendCell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
            friendForIndexPath(indexPath, cell: friendCell)
            return friendCell
        }
        if(collectionView == self.similarPicsCollectionView)
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SimiCell", forIndexPath: indexPath) as! SimiCollCell
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
        else {
            let venuePhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCollectionCell", forIndexPath: indexPath) as! PhotosCollectionViewCell
            venuePhotoForIndexPath(indexPath, cell: venuePhotoCell)
            venuePhotoCell.backgroundColor = UIColor.whiteColor()
            return venuePhotoCell
        }
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

        self.similarPicsCollectionView.reloadData()
        
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

    func friendForIndexPath(indexPath: NSIndexPath, cell: FriendCell) {
        let pic = self.friendPics![indexPath.row]
        /*
        pic.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) in
            if data != nil {
                let image = UIImage(data: data!)
                cell.friendPicView.image = image
                cell.friendPicView.layer.cornerRadius = cell.friendPicView.frame.height/2
                cell.friendPicView.clipsToBounds = true
            }
        }*/
        
    }
    
    func venuePhotoForIndexPath(indexPath: NSIndexPath, cell: PhotosCollectionViewCell) {
        let urlString = self.venuePhotos![indexPath.row]
        print("URL STRING: \(urlString)")
        let url = NSURL(string: urlString)
        //cell.photoCellImage.setImageWithURL(url!)
    }
    
    func initializeMapView() {
        let lat = card!["latitude"] as! Double
        let lng = card!["longitude"] as! Double
        
        self.cardLat = lat
        self.cardLong = lng
        if currLat != nil || currLong != nil {
            let latDiff = 2*abs(lat - currLat!)
            let lngDiff = abs(lng - currLong!)
            print(latDiff)
            print(lngDiff)
            let diff = max(latDiff, lngDiff)
            
            let currRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake((currLat! + lat)/2, (currLong! + lng)/2), MKCoordinateSpanMake(diff, diff))
            mapView.setRegion(currRegion, animated: false)

        }
        let cardLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let cardAnnotation = MKPointAnnotation()
        cardAnnotation.coordinate = cardLocation
        let addresses = card!["addressArray"] as! [String]
        let address = addresses[0]
        cardAnnotation.title = "\(address)"

        mapView.addAnnotation(cardAnnotation)
    }
    func initializeFBShare() {
        let sharePhoto = FBSDKSharePhoto()
        let content = FBSDKSharePhotoContent()
        
        sharePhoto.userGenerated = true
        let imageFile = card!["media"] as? PFFile
        imageFile?.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
            if data != nil {
                let image = UIImage(data: data!)
                sharePhoto.image = image
                content.photos = [sharePhoto]

                self.button.shareContent = content
                //self.button.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 100) * 0.4, 250, 100, 25)
                //self.masterView.addSubview(self.button)
                
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return reviews?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reviewCell = tableView.dequeueReusableCellWithIdentifier("ReviewTableCell") as! ReviewTableCell
        let review = reviews![indexPath.row]
        review.fetchInBackgroundWithBlock { (review: PFObject?, error: NSError?) in
            if review != nil {
                reviewCell.reviewLabel!.text = review!["text"] as? String
                let author = review!["author"] as! PFUser
                author.fetchInBackgroundWithBlock({ (user: PFObject?, error: NSError?) in
                    if user != nil {
                        let imageFile = author["profileImage"] as! PFFile
                        imageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
                            if data != nil {
                                let image = UIImage(data: data!)
                                reviewCell.profPicView.image = image
                                reviewCell.profPicView.layer.cornerRadius = reviewCell.frame.height/2
                                reviewCell.profPicView.clipsToBounds = true
                            }
                            else {
                                print(error)
                            }
                        })
                    }
                    else {
                        print("could not fetch author")
                        print(error)
                    }
                })
                
            }
        }
        return reviewCell
    }
    
    @IBAction func mapTapped(sender: AnyObject) {
        if cardLat != nil && cardLong != nil {
            let appleMapsURL = "http://maps.apple.com/?q=\(cardLat!),\(cardLong!)"
            UIApplication.sharedApplication().openURL(NSURL(string: appleMapsURL)!)
            
        }
    }
    /*
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        /*
        if annotationView == nil {
            //annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView = MKPinAnnotationView()
            annotationView.pin
            
        }*/
        //annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        //annotationView = MKPinAnnotationView()
        //annotationView.pinTintColor = UIColor.purpleColor()
        
        //annotationView?.canShowCallout = true
        //annotationView?.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
        //let btn = UIButton(type: .DetailDisclosure)
        //annotationView!.rightCalloutAccessoryView = btn
        
        //let resizeRenderImageView = UIImageView(frame: CGRectMake(0, 0, 45, 45))
        /*
        let resizeRenderImageView = UIImageView(frame: CGRectMake(0, 0, 45, 45))
                //resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        
        let imageFile = card!["media"] as! PFFile
        
        resizeRenderImageView.layer.borderColor = UIColor.whiteColor().CGColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.layer.cornerRadius = resizeRenderImageView.frame.height/2

        imageFile.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) in
            
            if data != nil {
                print("image loaded")
                let image = UIImage(data: data!)
                resizeRenderImageView.image = image
                
                UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
                resizeRenderImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                annotationView.image = thumbnail

            }
            else {
                print(error)
            }
            
        }*/
        
        //resizeRenderImageView.file = card!["media"] as? PFFile
                //resizeRenderImageView.contentMode = UIViewContentMode.ScaleAspectFill

        //resizeRenderImageView.loadInBackground()
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let annotations = [mapView.userLocation, view.annotation!]
        mapView.showAnnotations(annotations, animated: true)

    }*/
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        UIApplication.sharedApplication().openURL(URL)
        return false
    }
    
    func getVenueInfo() {
        if card!["venueId"] != nil {
            let fourSquareInfo = FourSquareClient()
            let venueID = card!["venueId"] as! String
            print(venueID)
            fourSquareInfo.fetchVenueInfo(venueID, completion: { (venueInfo: Venue) in
                self.venue = venueInfo
                //print("The venus has: \(self.venue)")
                //print("venues: \(self.venue)")
                if let name = self.venue?.name {
                    self.venueNameLabel.text = name
                } else {
                    self.venueNameLabel.text = "Anonymous Location"
                }
                if self.venue!.hours.count != 0 {
                    //print("The hours: \(hoursInfo)")
                    let hoursInfo = self.venue!.hours
                    if hoursInfo["timeframes"] != nil {
                        let timeFrame = hoursInfo["timeframes"] as! NSArray
                        var timeTable = ""
                        var newTimeTable = ""
                        for time in timeFrame {
                            
                            if let timeKeys = time as? NSDictionary {
                                let day = timeKeys["days"] as? String
                                if let openTimes = timeKeys["open"] as? NSArray {
                                    var openTimeTable = ""
                                    for renderedTime in openTimes {
                                        if let renderedTimeFrameDictionary = renderedTime as? NSDictionary {
                                            let actualTimeFrame = renderedTimeFrameDictionary["renderedTime"] as! String
                                            openTimeTable = openTimeTable + actualTimeFrame + "\n"

                                        } else {
                                            let actualTimeFrame = "no time frame"
                                            openTimeTable = openTimeTable + actualTimeFrame

                                        }
                                        newTimeTable = day! + "\n" + openTimeTable 
                                
                                    }
                                    timeTable = timeTable + newTimeTable
                                    
                                }
                                
                            }
                        }
                        print("TimeTABLE: \(timeTable)")
                        self.hoursLabel.text = timeTable
                    } else {
                        self.hoursLabel.text = "Hours not available" 
                    }
                    
                } else {
                    self.hoursLabel.text = "Hours: It's high noon"
                }
                if let websiteUrlString = self.venue?.url {
                    self.url = websiteUrlString
                    
                } else {
                    self.url = "no url"
                }
                if let photoInfo = self.venue!.photos as? NSDictionary {
                    if let groups = photoInfo["groups"] as? NSArray {
                        if groups.count > 0 {
                        if let items = groups[0] as? NSDictionary {
                            for photoInfo in items {
                                print(photoInfo)
                                if photoInfo.key as! String == "items" {
                                    print("key found")
                                    
                                    if let photoList = photoInfo.value as? NSArray {
                                        print("array exist")
                                        for item in photoList {
                                            if let itemDictionary = item as? NSDictionary {
                                                print("dictionary exist")
                                                let prefix = itemDictionary["prefix"] as! String
                                                let suffix = itemDictionary["suffix"] as! String
                                                let size = "400x400"
                                                let url = prefix + size + suffix
                                                self.venuePhotos?.append(url)
                                            }
                                        }
                                        self.photosCollectionView.reloadData()
                                    }
                                    
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    }
                    
                }
                
                print("done")
            })
            
        } else {
            print("sorry man")
        }

        
    }
    
    func pauseVideo(sender: UITapGestureRecognizer) {
        print("video tapped")
        NSNotificationCenter.defaultCenter().postNotificationName("ShowVideoButton", object: nil)
        //let currentMainView = self.mainViews[kolodaView.currentCardIndex]
        if self.player != nil {
            if self.player!.rate != 0 {
                self.player!.pause()
            }
        }
    }
    
    func populateLabels() {
        videoView.backgroundColor = UIColor.clearColor()
        let query = PFQuery(className: "UserCard")
        if let price = card!["price"] as? Int {
            var priceString = ""
            if price == 0 {
                priceString = "Free!"
            }
            else {
                for _ in 1...price {
                    priceString += "$"
                }
            }
            
            
            self.estimatedPriceLabel.text = priceString
        } else {
            print("check this error!!! price shouldn't be nil")
            self.estimatedPriceLabel.text = "Nil??"
        }
        
        if self.card!["videoData"] != nil {
            //self.videoFilePath = mainViews[Int(index)].currentCard["videoFilePath"] as? String
            
            //let theplayer = mainViews[Int(index)].player
            let tap = UITapGestureRecognizer(target: self, action: #selector(pauseVideo(_:)))
            //tap.delegate = cardPicture
            videoView.userInteractionEnabled = true
            videoView.addGestureRecognizer(tap)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.showPlayButton), name: "ShowVideoButton", object: nil)
            
            card!["videoData"].getDataInBackgroundWithBlock({ (videoData: NSData?, error: NSError?) in
                let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                let filePath = documentsPath.stringByAppendingString("/wolf.mov")
                do {
                    try videoData!.writeToFile(filePath, options: .DataWritingAtomic)
                }
                catch {
                    print(error)
                }
                
                let defaultManager = NSFileManager()
                if defaultManager.fileExistsAtPath(filePath) {
                    print(true)
                }
                else {
                    print(false)
                }
                
                /*
                 let url = NSURL(fileURLWithPath: filePath)
                 let player = AVPlayer(URL: url)
                 let playerVC = AVPlayerViewController()
                 playerVC.player = player
                 playerVC.view.frame = self.mainViews[self.kolodaView.currentCardIndex].frame
                 self.presentViewController(playerVC, animated: true, completion: {
                 playerVC.showsPlaybackControls = true
                 })*/
                
                let url = NSURL(fileURLWithPath: filePath)
                let player = AVPlayer(URL: url)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = CGRectMake(0.0, 0.0, 375.0, 375.0)
                self.videoView.layer.addSublayer(playerLayer)
                self.player = player
                
                
                NSNotificationCenter.defaultCenter().addObserver(self,
                    selector: #selector(self.playerItemDidReachEnd(_:)),
                    name: AVPlayerItemDidPlayToEndTimeNotification,
                    object: player.currentItem)

                //player.play()
            })
            
            let button = UIButton()
            button.frame = CGRectMake(150, 150, 80, 80)
            button.setBackgroundImage(UIImage(named: "playbutton"), forState: UIControlState.Normal)
            //button.backgroundColor = UIColor.blackColor()
            button.addTarget(self, action: #selector(self.playVideo(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.playButton = button
            self.videoView.addSubview(button)
            
            /*
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.alpha = 0.7
            blurEffectView.frame = self.cardPicture.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
            self.cardPicture.addSubview(blurEffectView)*/
        }
        
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
       
       
        
       
        /*
        if let createdAt = card!.createdAt {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            let createdAtString = dateFormatter.stringFromDate(createdAt)
            self.whenSavedLabel.text = "Saved on " + createdAtString
        } else {
            self.whenSavedLabel.text = "Saved on IDK FAM"
        }*/
        if let addresses = card!["addressArray"] as? [String] {
            print(addresses.count)
            var addressString = ""
            
            for address in addresses {
                addressString += (address + "\n")
            }
            
            self.addressLabel.text = addressString
            
        } else {
            self.addressLabel.text = ""
        }
        let gotLat = card!["latitude"] as! Double
        let gotLong = card!["longitude"] as! Double
        let mainVC = MainViewController()
        mainVC.getDistance2(self.currLat!, long1: self.currLong!, lat2: gotLat, long2: gotLong) { (distanceString: String?, error: NSError?) in
            if error != nil {
                print(error)
            }
            else {
                self.distance = distanceString
                self.distanceLabel.text = "Distance: \(distanceString!)"
            }
        }
        query.whereKey("userCardId", equalTo: (user?.username)! + "$" + (card?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (savedTime:[PFObject]?, error: NSError?) in
            if savedTime?.count > 0 {
                if let userCard = savedTime![0] as? PFObject{
                    if let whenSaved = userCard["date"] as? NSDate {
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateStyle = .ShortStyle
                        let createdAtString = dateFormatter.stringFromDate(whenSaved)
                        print("CREATED STRING: \(createdAtString)")
                        self.whenSavedLabel.text = "Saved on " + createdAtString
                    }

                    
                }
            }
        }
        
        
        
        //self.distanceLabel.text = "Distance: \(distance!)"
        
    }
    
    func showPlayButton() {
        self.playButton?.hidden = false
    }
    
    func playVideo(sender: UIButton) {
        sender.hidden = true
        if self.player != nil {
            if self.player!.rate == 0 {
                self.player!.play()
            }
        }
        
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.player!.seekToTime(CMTimeMakeWithSeconds(0, 600))
        self.player!.play()
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
        
        if segue.identifier == "reviewSegue" {
            let reviewVC = segue.destinationViewController as! ReviewViewController
           
            reviewVC.card = self.card
            print("review is transfered")
        }
        else if segue.identifier == "venuePhotoSegue" {
            let venuePhotoVC = segue.destinationViewController as! VenuePhotosViewController
            let indexPath = photosCollectionView.indexPathForCell(sender as! UICollectionViewCell)
            let urlString = self.venuePhotos![indexPath!.row]
            print("we good with: \(urlString)")
            venuePhotoVC.url = urlString
            
        }
        else if segue.identifier == "infoSegue" {
            let infoVC = segue.destinationViewController as! InfoViewController
            infoVC.card = self.card
            infoVC.venue = self.venue
            infoVC.currLat = self.currLat
            infoVC.currLong = self.currLong
        }
        else if segue.identifier == "detailToMoreDetailSegue" {
            let similarDetailVC = segue.destinationViewController as! SimilarDetailViewController
            let indexPath = similarPicsCollectionView.indexPathForCell(sender as! UICollectionViewCell)
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
    

}
