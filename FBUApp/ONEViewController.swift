//
//  ONEViewController.swift
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

class ONEViewController: UIViewController {

    @IBOutlet weak var detailView1: UIView!
    @IBOutlet weak var cardPicture: UIImageView!
    @IBOutlet weak var gradientView1: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView1: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateSavedLabel: UILabel!
    
    @IBOutlet weak var shareOnFBButton: UIButton!
    let button : FBSDKShareButton = FBSDKShareButton()
    //@IBOutlet weak var newNameLabel: UILabel!
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
    var player: AVPlayer?
    var playButton: UIButton?
    var videoView: UIView?
    
    @IBAction func shareOnFBTapped(sender: AnyObject) {
        button.sendActionsForControlEvents(.TouchUpInside)
    }
    @IBAction func mapTapped(sender: AnyObject) {
        if card!["latitude"] != nil && card!["longitude"] != nil {
            let cardLat = card!["latitude"] as! Double
            let cardLong = card!["longitude"] as! Double
            
            let appleMapsURL = "http://maps.apple.com/?q=\(cardLat),\(cardLong)"
            UIApplication.sharedApplication().openURL(NSURL(string: appleMapsURL)!)
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
    
    func showPlayButton() {
        self.playButton?.hidden = false
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.player!.seekToTime(CMTimeMakeWithSeconds(0, 600))
        self.player!.play()
    }
    
    func initializeVideo() {
        if self.card!["videoData"] != nil {
            //self.videoFilePath = mainViews[Int(index)].currentCard["videoFilePath"] as? String
            let videoView = UIView()
            self.videoView = videoView
            videoView.frame = cardPicture.frame
            //let theplayer = mainViews[Int(index)].player
            let tap = UITapGestureRecognizer(target: self, action: #selector(pauseVideo(_:)))
            //tap.delegate = cardPicture
            gradientView1.userInteractionEnabled = true
            gradientView1.addGestureRecognizer(tap)
            
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
                self.videoView!.layer.addSublayer(playerLayer)
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
            //self.videoView!.addSubview(button)
            self.view.addSubview(button)
            self.view.insertSubview(videoView, belowSubview: gradientView1)
            
            /*
             let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
             let blurEffectView = UIVisualEffectView(effect: blurEffect)
             blurEffectView.alpha = 0.7
             blurEffectView.frame = self.cardPicture.bounds
             blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
             self.cardPicture.addSubview(blurEffectView)*/
        }
    }
    
    func playVideo(sender: UIButton) {
        sender.hidden = true
        if self.player != nil {
            if self.player!.rate == 0 {
                self.player!.play()
            }
        }
        
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

    override func viewDidLoad() {
        super.viewDidLoad()
        getVenueInfo()
        
        initializeVideo()
        
        initializeFBShare()
        shareOnFBButton.addTarget(self, action: #selector(DetailViewController.shareOnFBTapped(_:)), forControlEvents: .TouchUpInside)
        
        //PICTURE
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
        //GRADIENT
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = gradientView1.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        gradient.locations = [0.0, 0.58]


        gradientView1.layer.addSublayer(gradient)
        
        
        //PRICE
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
        
        //ALPHA FADING
        
        //detailLabel.alpha = 0.0
        nameLabel.alpha = 0.0
        nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 26)
        mapView1.alpha = 0.0
        addressLabel.alpha = 0.0
        addressLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        priceLabel.alpha = 0.0
        priceLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        distanceLabel.alpha = 0.0
        distanceLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        dateSavedLabel.alpha = 0.0
        dateSavedLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        detailView1.alpha = 0.0
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            //self.detailLabel.alpha = 1.0
            self.nameLabel.alpha = 1.0
            self.mapView1.alpha = 1.0
            self.addressLabel.alpha = 1.0
            
            self.priceLabel.alpha = 1.0
            self.distanceLabel.alpha = 1.0
            self.dateSavedLabel.alpha = 1.0
            self.detailView1.alpha = 1.0
            }, completion: nil)
        
        //Set distance, date saved, and map view
        setDistance()
        whenSaved()
        initializeMapView()
        
        //Set address
        if let addresses = card!["addressArray"] as? [String] {
            print(addresses.count)
            var addressString = ""
            
            for address in addresses {
                if address != "United States" {
                    addressString += (address + "\n")
                }
                
            }
            
            self.addressLabel.text = addressString
            
        } else {
            self.addressLabel.text = ""
        }

        self.nameLabel.text = "hello"
        //Name label
        /*
        if let name = self.venue?.name {
            self.nameLabel.text = name
        } else {
            self.nameLabel.text = "No name"
        }*/


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
                    self.nameLabel.text = name
                    //self.newNameLabel.text = name
                } else {
                    self.nameLabel.text = "Anonymous Location"
                }
                if let websiteUrlString = self.venue?.url {
                    self.url = websiteUrlString
                    
                } else {
                    self.url = "no url"
                }
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
                        //dateFormatter.dateStyle = .ShortStyle
                        dateFormatter.dateFormat = "MMM d"
                        let createdAtString = dateFormatter.stringFromDate(whenSaved)
                        self.savedString = createdAtString
                        self.dateSavedLabel.text = createdAtString
                    }
                    
                    
                }
            }
        }
    }
    
    @IBAction func onWebsiteTap(sender: AnyObject) {
        if let url = NSURL(string: self.url!) {
            UIApplication.sharedApplication().openURL(url)
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
            mapView1.setRegion(currRegion, animated: false)
            
        }
        let cardLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let cardAnnotation = MKPointAnnotation()
        cardAnnotation.coordinate = cardLocation
        let addresses = card!["addressArray"] as! [String]
        let address = addresses[0]
        cardAnnotation.title = "\(address)"
        
        mapView1.addAnnotation(cardAnnotation)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
