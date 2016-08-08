//
//  InfoViewController.swift
//  FBUApp
//
//  Created by Angeline Rao on 7/28/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse
import MapKit
import ParseFacebookUtilsV4
import FBSDKShareKit

//class InfoViewController: UIViewController, iCarouselDelegate, iCarouselDataSource {
class InfoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var friendCollectionView: UICollectionView!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet var carouselView: iCarousel!
    //@IBOutlet weak var carousel: iCarousel!
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
    var url: String?
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet var carousel: iCarousel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var hoursLabel: UILabel!
    //@IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardPicture: UIImageView!
    //@IBOutlet weak var cardPicture: ImageViewWithGradient!
    override func viewDidLoad() {
        super.viewDidLoad()
        venuePhotos = []
        getVenueInfo()
        initializeFBShare()
         reviews = card!["reviews"] as? [PFObject]
        let navBar = navigationController!.navigationBar
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        navBar.translucent = true
        navigationController!.view.backgroundColor = UIColor.clearColor()
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, scrollView.frame.height*1.5 - 65.0)
        populateFriends()
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        friendCollectionView.dataSource = self
        friendCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self

        //carouselView.delegate = self
        //carouselView.dataSource = self
        //carouselView.type = iCarouselType.CoverFlow
        setDistance()
        whenSaved()
        initializeMapView()
        if let addresses = card!["addressArray"] as? [String] {
            print(addresses.count)
            var addressString = ""
            var index = 0
            var firstLine = NSAttributedString(string: "")
            for address in addresses {
            
                if index == 0  && addresses.count >= 3 {
                    firstLine = NSAttributedString(string: address + "\n", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)])
                }
                else if address == "United States" {
                    addressString += ""
                    
                } else {
                addressString += (address + "\n")
                }
                index += 1
            }
            
            //self.addressLabel.attributedText = firstLine + addressString
            self.addressLabel.text = addressString
            
        } else {
            self.addressLabel.text = ""
        }
        
        if let name = self.venue?.name {
            self.nameLabel.text = name
        } else {
            self.nameLabel.text = "No name"
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
        //cardPicture.setup()
        
        //gradientView.backgroundColor = UIColor.clearColor()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = gradientView.bounds
        //gradient.colors = [UIColor(white: 1.0, alpha: 0.0).CGColor, UIColor.blackColor().CGColor]
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        gradient.locations = [0.0, 0.29]
        
        
        //gradient.opaque = false
        
        //cardPicture.layer.mask = gradient
        //gradientView.layer.insertSublayer(gradient, atIndex: 0)\
        //cardPicture.layer.addSublayer(gradient)
        //cardPicture.layer.insertSublayer(gradient, atIndex: 0)
        //gradientView.layer.addSublayer(gradient)
        //gradientView.alpha = 0.3
       
        
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
            self.priceLabel.text = priceString + " • "

        }
        
        //detailLabel.text = "\(priceString) • \(distance) • \(savedString)"
        
        //detailLabel.alpha = 0.0
        nameLabel.alpha = 0.0
        nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
        mapView.alpha = 0.0
        addressLabel.alpha = 0.0
        addressLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        priceLabel.alpha = 0.0
        priceLabel.font =  UIFont(name: "HelveticaNeue-Thin", size: 16)
        distanceLabel.alpha = 0.0
        distanceLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        savedLabel.alpha = 0.0
        savedLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        detailView.alpha = 0.0
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            //self.detailLabel.alpha = 1.0
            self.nameLabel.alpha = 1.0
            self.mapView.alpha = 1.0
            self.addressLabel.alpha = 1.0
            
            self.priceLabel.alpha = 1.0
            self.distanceLabel.alpha = 1.0
            self.savedLabel.alpha = 1.0
            self.detailView.alpha = 1.0
        }, completion: nil)
        
    }
    /*
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return 3
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        
        let pictureView = UIView()
        pictureView.frame = CGRectMake(0, 0, 100, 100)
        
        let picture = UIImageView()
        picture.frame = pictureView.frame
        picture.image = UIImage(named: "ny_3-4")
        pictureView.addSubview(picture)
        return pictureView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 1.1
        }
        return value
    }*/
    /*
    func shareOnMessenger(sender: UIButton) {
        let imageFile = card!["media"] as? PFFile
        imageFile?.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
            if data != nil {
                let image = UIImage(data: data!)
                FBSDKMessengerSharer.shareImage(image, withOptions: nil)
                
                //self.button.shareContent = content
                //self.button.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 100) * 0.4, 250, 100, 25)
                //self.masterView.addSubview(self.button)
                
            }
        })
    }*/
    
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
                
                //self.button.shareContent = content
                //self.button.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 100) * 0.4, 250, 100, 25)
                //self.masterView.addSubview(self.button)
                
            }
        })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reviewCell = tableView.dequeueReusableCellWithIdentifier("ReviewTableCell", forIndexPath: indexPath) as! ReviewTableCell
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
    
    func friendForIndexPath(indexPath: NSIndexPath, cell: FriendCell) {
        let pic = self.friendPics![indexPath.row]
        pic.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) in
            if data != nil {
                let image = UIImage(data: data!)
                cell.friendView.image = image
                cell.friendView.layer.cornerRadius = cell.friendView.frame.height/2
                cell.friendView.clipsToBounds = true
            }
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.friendCollectionView {
            return self.friendPics?.count ?? 0
        }
        if collectionView == self.photosCollectionView {
            print("The VENU HAS: \(venuePhotos?.count)")
            return self.venuePhotos?.count ?? 0
            
        }

        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        

        if collectionView == self.friendCollectionView {
            let friendCell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
            friendForIndexPath(indexPath, cell: friendCell)
            return friendCell
            
        } else {
            let venuePhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionCell", forIndexPath: indexPath) as! PhotosCollectionViewCell
            venuePhotoForIndexPath(indexPath, cell: venuePhotoCell)
            venuePhotoCell.backgroundColor = UIColor.blueColor()
            return venuePhotoCell
        }

        
    }
    func venuePhotoForIndexPath(indexPath: NSIndexPath, cell: PhotosCollectionViewCell) {
        let urlString = self.venuePhotos![indexPath.row]
        print(urlString)
        let url = NSURL(string: urlString)
        print("THA URL: \(url)")
        if url != nil {
        //cell.photoCellImage.setImageWithURL((url)!)
        }
    }

    
    @IBAction func onVenuePhotoTap(sender: AnyObject) {
    }
    
    @IBAction func onWebsiteTap(sender: AnyObject) {
        if let url = NSURL(string: self.url!) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
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
            
            FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields" : "name"], HTTPMethod: "GET").startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, response: AnyObject!, error: NSError!) in
                if response != nil {
                    let dict = response as! NSDictionary
                    let allFriends = dict.valueForKey("data") as! NSArray
                    for friend in allFriends {
                        print(allFriends.count)
                        print(friend)
                        let dict = friend as! NSDictionary
                        let fbId = dict["id"] as! String
                        print(fbId)
                        //query!.whereKey("fbId", equalTo: fbId)
                        //query!.whereKeyExists("fbId")
                        
                        //query?.whereKey("fbId", hasPrefix: fbId)
                        let query = PFUser.query()
                        //query!.whereKeyExists("fbId")
                        query!.whereKey("fbId", containedIn: [fbId])
                        query!.findObjectsInBackgroundWithBlock({ (friends: [PFObject]?, error: NSError?) in
                            if friends != nil {
                                print(friends)
                                print(self.card)
                                let friend = friends![0]
                                friend.fetchIfNeededInBackgroundWithBlock({ (friend: PFObject?, error: NSError?) in
                                    if friend != nil {
                                        print(friend)
                                        let saved = friend!["savedCards"] as! [PFObject]
                                        print(saved)
                                        let objectId = self.card!.objectId
                                        
                                        for card in saved {
                                            print(card.objectId)
                                            print(objectId)
                                            if card.objectId == objectId {
                                                print("same")
                                                let imageFile = friend!["profileImage"] as! PFFile
                                                self.friendPics?.append(imageFile)
                                                break
                                                
                                            }
                                        }
                                        
                                        
                                    }
                                    self.friendCollectionView.reloadData()
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
    func getVenueInfo() {
        if card!["venueId"] != nil {
            let fourSquareInfo = FourSquareClient()
            let venueID = card!["venueId"] as! String
            print(venueID)
            fourSquareInfo.fetchVenueInfo(venueID, completion: { (venueInfo: Venue) in
                self.venue = venueInfo
                //print("The venus has: \(self.venue)")
                //print("venues: \(self.venue)")
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
                                                    print("The VENU ACTUALLY HAS: \(self.venuePhotos?.count)")
                                                    
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

    
    func setDistance() {
        let gotLat = card!["latitude"] as! Double
        let gotLong = card!["longitude"] as! Double
        let mainVC = MainViewController()
        mainVC.getDistance2(self.currLat!, long1: self.currLong!, lat2: gotLat, long2: gotLong) { (distanceString: String?, error: NSError?) in
            if error != nil {
                print(error)
            }
            else {
                self.distance = distanceString
                self.distanceLabel.text = distanceString! + " • "
                //self.distanceLabel.text = "Distance: \(distanceString!)"
            }
        }
    }
    
    func whenSaved() {
        let user = PFUser.currentUser()
        let query = PFQuery(className: "UserCard")
        query.whereKey("userCardId", equalTo: (user?.username)! + "$" + (card?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (savedTime:[PFObject]?, error: NSError?) in
            if savedTime?.count > 0 {
                if let userCard = savedTime![0] as? PFObject{
                    if let whenSaved = userCard["date"] as? NSDate {
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateStyle = .ShortStyle
                        let createdAtString = dateFormatter.stringFromDate(whenSaved)
                        self.savedString = createdAtString
                        self.savedLabel.text = createdAtString
                    }
                    
                    
                }
            }
        }
    }
    
    func initializeMapView() {
        let lat = card!["latitude"] as! Double
        let lng = card!["longitude"] as! Double
        
        //self.cardLat = lat
        //self.cardLong = lng
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
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
