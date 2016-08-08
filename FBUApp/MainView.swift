//
//  MainView.swift
//  FBUApp
//
//  Created by Angeline Rao on 7/6/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import AVFoundation
import AVKit
import AssetsLibrary
import MapKit

enum Swipe {
    case Left
    case Right
    case Up
    case Down
}

class MainView: UIView, UIGestureRecognizerDelegate {
    let imageMarginSpace: CGFloat = 3.0
    //var pictureView: PFImageView!
    var pictureView: UIImageView!
    var videoView: UIView!
    var likesLabel: UILabel!
    var distanceLabel: UILabel!
    var originalCenter: CGPoint!
    var animator: UIDynamicAnimator!
    var currentCard: PFObject!
    var labelsView: UIView!
    var gradientLayer = CAGradientLayer()
    var player: AVPlayer?
    var frontView: UIView?
    var backView: UIView?
    var currLong: Double?
    var currLat: Double?
    var backLabelView: UIView?
    var backLeftLabel: UILabel?
    var backRightLabel: UILabel?
    var venue : Venue?
    //var card: PFObject?
    
    func pauseVideo(sender: UITapGestureRecognizer) {
        print("video tapped pause video")
        NSNotificationCenter.defaultCenter().postNotificationName("ShowVideoButton", object: nil)
        //let currentMainView = self.mainViews[kolodaView.currentCardIndex]
        if self.player != nil {
            if self.player!.rate != 0 {
                self.player!.pause()
            }
        }
    }
    
    func initializeMapView() -> MKMapView {
        let mapView = MKMapView()
        let card = self.currentCard
        let lat = card!["latitude"] as! Double
        let lng = card!["longitude"] as! Double
        
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
        let addresses = card["addressArray"] as! [String]
        let address = addresses[0]
        cardAnnotation.title = "\(address)"
        mapView.addAnnotation(cardAnnotation)
        
        return mapView
    }
    
    
    //init(frame: CGRect, center: CGPoint, image: UIImage) {
    init(frame: CGRect, center: CGPoint, card: PFObject, distance: String, lat: Double, long: Double) {
        super.init(frame: frame)
        self.center = center
        self.originalCenter = center
        self.currLong = long
        self.currLat = lat
        //let angle = Double(arc4random_uniform(20)) - 10.0
        //self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * angle/1000))
        /*
         self.layer.shadowColor = UIColor.blackColor().CGColor
         self.layer.shadowOpacity = 0.5
         self.layer.shadowOffset = CGSizeZero
         self.layer.shadowRadius = 10
         self.layer.shouldRasterize = true*/
        
        //self.pictureView = PFImageView()
        //self.pictureView.file = file
        //self.pictureView.loadInBackground()
        /*
         if card == nil {
         self.pictureView.image = UIImage()
         self.likesLabel.text = ""
         self.distanceLabel.text = ""
         }
         else {*/
        self.currentCard = card
        self.pictureView = UIImageView()

        //self.pictureView.layer.cornerRadius = 10
        //self.pictureView.clipsToBounds = true
        
        //self.pictureView.image = image
        
        
        let frontView = UIView(frame: frame)
        
        let backView = UIView(frame: frame)
        
        backView.backgroundColor = UIColor.blackColor()
        
        let mapView = initializeMapView()
        mapView.frame = CGRectMake(0.0, 0.0, backView.frame.width, 160.0)
        mapView.mapType = .Standard
        mapView.showsUserLocation = true
        backView.addSubview(mapView)
        
        
        
        backLabelView = UIView()

        backLabelView!.frame = CGRectMake(10.0, 170.0, backView.frame.width, backView.frame.height - 170.0)
        backLabelView?.backgroundColor = UIColor.blackColor()
        backRightLabel = UILabel()
        getVenueInfo()

        
        backRightLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 18)
        backRightLabel!.textColor = UIColor.whiteColor()
        
        /*if card["location"] != nil {
            print(card["location"])
            backRightLabel!.text = card["location"] as? String
        }*/
        
        
        
        
        
        backLeftLabel = UILabel()
        backLeftLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 18)
        backLeftLabel!.textColor = UIColor.whiteColor()
        backLeftLabel!.frame = CGRectMake(0.0, 80.0, backView.frame.width, 100.0)
        backLeftLabel!.numberOfLines = 0
        let addresses = card["addressArray"] as! [String]
        var addressString = ""
        
        for address in addresses {
            if address != "United States" {
                addressString += (address + "\n")
            }
            
        }
        //print(addressString)
        backLeftLabel!.text = addressString
        backLabelView!.addSubview(backLeftLabel!)
        
        
        
        backView.addSubview(backLabelView!)
        
        labelsView = UIView()
        labelsView.frame = CGRectMake(0.0, 325.0, self.frame.width, 50.0)
        labelsView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        //labelsView.backgroundColor = UIColor.grayColor()
        //labelsView.backgroundColor = UIColor.clearColor()
        /*
         let gray = UIColor.grayColor().CGColor as CGColorRef
         let gray2 = UIColor.grayColor().colorWithAlphaComponent(0.1).CGColor as CGColorRef
         let gray3 = UIColor.grayColor().colorWithAlphaComponent(0.7).CGColor as CGColorRef
         let clear = UIColor.clearColor().CGColor as CGColorRef
         gradientLayer.frame = labelsView.bounds
         gradientLayer.colors = [clear, gray2, gray3, gray]
         gradientLayer.locations = [0.0, 0.3, 0.7, 1.0]
         labelsView.layer.addSublayer(gradientLayer)*/
        
        let likes = card["likesCount"] as! Int
        self.likesLabel = UILabel()
        
        if likes == 1 {
            self.likesLabel.text = "\(likes) like"
        }
        else {
            self.likesLabel.text = "\(likes) likes"
        }
        self.likesLabel.frame = CGRectIntegral(CGRectMake(
            0.0 + self.imageMarginSpace,
            0.0 + self.imageMarginSpace/4,
            150,
            50))
        self.likesLabel.textColor = UIColor.whiteColor()
        self.likesLabel.font = UIFont (name: "HelveticaNeue-Thin", size: 19)
        
        self.distanceLabel = UILabel()
        self.distanceLabel.text = distance
        
        self.distanceLabel.textColor = UIColor.whiteColor()
        self.distanceLabel.frame = CGRectIntegral(CGRectMake(
            self.frame.width - (2 * self.imageMarginSpace) - 55.0,
            0.0 + self.imageMarginSpace/4,
            150,
            50))
        self.distanceLabel.font = UIFont (name: "HelveticaNeue-Thin", size: 19)
        
        labelsView.addSubview(self.likesLabel)
        labelsView.addSubview(self.distanceLabel)
        self.videoView = UIView()
        self.videoView.backgroundColor = UIColor.clearColor()
        self.videoView.frame = frontView.frame
        
        if card["videoData"] != nil {
            card["videoData"].getDataInBackgroundWithBlock({ (videoData: NSData?, error: NSError?) in
                let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                let filePath = documentsPath.stringByAppendingString("/video.mov")
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
                playerLayer.frame = self.videoView.frame
                self.videoView.layer.addSublayer(playerLayer)
                self.player = player
                
                NSNotificationCenter.defaultCenter().addObserver(self,
                    selector: #selector(self.playerItemDidReachEnd(_:)),
                    name: AVPlayerItemDidPlayToEndTimeNotification,
                    object: player.currentItem)
                
                
                //player.play()
                
                
                self.addSubview(self.videoView)
                
            })
            
            
        }
        else {
            self.addSubview(self.videoView)
        }
        
        let imageFile = card["media"] as! PFFile
        var image = UIImage()
        imageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) in
            if imageData != nil {
                
                
                //self.insertSubview(self.likesLabel, atIndex: self.subviews.count - 1)
                self.pictureView.frame = CGRectIntegral(CGRectMake(
                    0.0,
                    0.0,
                    self.frame.width,
                    self.frame.height
                    ))
                image = UIImage(data: imageData!)!
                self.pictureView.image = image
                if card["videoData"] == nil {
                    
                    
                    self.animator = UIDynamicAnimator(referenceView: self)
                    /*
                     self.pictureView.frame = CGRectIntegral(CGRectMake(
                     0.0 + self.imageMarginSpace,
                     0.0 + self.imageMarginSpace,
                     self.frame.width - (2 * self.imageMarginSpace),
                     self.frame.height - (2 * self.imageMarginSpace)
                     ))*/
                    
                    
                    
                }
                else {
                    //self.pictureView.backgroundColor = UIColor.blackColor()
                    
                    
                    
                    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    //blurEffectView.alpha = 0.2
                    blurEffectView.frame = self.pictureView.bounds
                    blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
                    
                    self.pictureView.addSubview(blurEffectView)
                    /*let imageToBlur = CIImage(image: image)
                    let blurfilter = CIFilter(name: "CIGaussianBlur")
                    blurfilter!.setValue(imageToBlur, forKey: "inputImage")
                    blurfilter!.setValue(20, forKey: "inputRadius")
                    let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
                    var blurredImage = UIImage(CIImage: resultImage)
                    var cropped:CIImage=resultImage.imageByCroppingToRect(CGRectMake(0, 0,imageToBlur!.extent.size.width, imageToBlur!.extent.size.height))
                    blurredImage = UIImage(CIImage: cropped)
                    let imageView = UIImageView(image: blurredImage)
                    self.pictureView.addSubview(imageView)*/

                }
                //frontView.addSubview(self.pictureView)
                //frontView.insertSubview(self.pictureView, aboveSubview: self.videoView)
                frontView.insertSubview(self.pictureView, belowSubview: self.videoView)
                //frontView.addSubview(self.labelsView)
                frontView.insertSubview(self.labelsView, aboveSubview: self.pictureView)
                //self.addSubview(self.likesLabel)
                
            }
        }
        self.frontView = frontView
        self.backView = backView
        
        self.addSubview(frontView)
        self.addSubview(backView)
        backView.hidden = true
        
        
        //}
        
    }
    
    func videoImageTapped(sender: UIButton) {
        let card = self.currentCard
        print("video tapped")
        print(card["videoUrl"])
        let urlString = card["videoUrl"] as! String
        let url = NSURL(string: urlString)
        print(urlString)
        
        let player = AVPlayer(URL: url!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.frame
        self.layer.addSublayer(playerLayer)
        self.player = player
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playerItemDidReachEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        player.play()
        
        /*
         let player = AVPlayer(URL: url!)
         let playerViewController = AVPlayerViewController()
         playerViewController.player = player
         */
        
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.player!.seekToTime(CMTimeMakeWithSeconds(0, 600))
        self.player!.play()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func swipe(swipe: Swipe) {
        animator.removeAllBehaviors()
        
        // If the answer is false, Move to the left
        // Else if the answer is true, move to the right
        var gravityX = 0.0
        var gravityY = 0.0
        var magnitude = 0.0
        if swipe == Swipe.Left {
            gravityX = -0.5
            magnitude = -20.0
        }
        else if swipe == Swipe.Right {
            gravityX = 0.5
            magnitude = 20.0
        }
        else if swipe == Swipe.Down {
            gravityY = 0.5
            magnitude = 20.0
        }
        
        //let gravityX = answer ? 0.5 : -0.5
        //let magnitude = answer ? 20.0 : -20.0
        let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items: [self])
        gravityBehavior.gravityDirection = CGVectorMake(CGFloat(gravityX), CGFloat(gravityY))
        animator.addBehavior(gravityBehavior)
        
        let pushBehavior:UIPushBehavior = UIPushBehavior(items: [self], mode: UIPushBehaviorMode.Instantaneous)
        if swipe == Swipe.Down {
            pushBehavior.setAngle(CGFloat(M_PI_2), magnitude: CGFloat(magnitude))
        }
        pushBehavior.magnitude = CGFloat(magnitude)
        animator.addBehavior(pushBehavior)
        
    }
    
    func returnToCenter() {
        UIView.animateWithDuration(0.8, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: {
            self.center = self.originalCenter
            }, completion: { finished in
                print("Finished Animation")}
        )
        
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func getVenueInfo() {
        if currentCard!["venueId"] != nil {
            let fourSquareInfo = FourSquareClient()
            let venueID = currentCard!["venueId"] as! String
            print(venueID)
            fourSquareInfo.fetchVenueInfo(venueID, completion: { (venueInfo: Venue) in
                
                self.venue = venueInfo
                if let name = self.venue?.name {
                    self.backRightLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 18)
                    self.backRightLabel!.frame = CGRectMake(0.0, 30.0, self.backView!.frame.width, 100.0)
                    self.backRightLabel!.textColor = UIColor.whiteColor()
                    self.backRightLabel!.text = name
                    self.backLabelView!.addSubview(self.backRightLabel!)
                    print(self.venue?.name)
                } else {
                    self.backRightLabel!.text = "Anonymous Location"
                    print("anon")
                }
                print("done")
            })
            
        } else {
            print("sorry man")
        }
        
        
    }
}
