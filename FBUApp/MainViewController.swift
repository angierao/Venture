//
//  MainViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/5/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

// pls merge
// MERGE


//
//  MainViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/5/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

// pls merge
// MERGE


import UIKit
import Parse
import ParseUI
import CoreLocation
import AFNetworking
import ParseFacebookUtilsV4
import MBProgressHUD
import AVKit
import AVFoundation
import Koloda
import ARSLineProgress

/*
 enum Swipe {
 case Left
 case Right
 case Up
 case Down
 }*/

class MainViewController: UIViewController, CLLocationManagerDelegate, KolodaViewDelegate, KolodaViewDataSource, Dimmable, SettingsViewControllerDelegate {
    
    @IBOutlet weak var kolodaView: KolodaView!
    var radiusInfo: Int = 50
    
    let savedKey: String = "savedCards"
    
    let METERS_PER_MILE = 1609.344
    
    let dimLevel: CGFloat = 0.8
    let dimSpeed: Double = 0.5
    var loads: Int = 0
    
    var numLoaded: Int = 0
    var numInStack: Int = 0
    var numInRange: Int = 0
    var numNotInRange: Int = 0
    
    var distanceData :NSDictionary?
    
    var distance = ""
    
    var cards: [PFObject]?
    var saved: [PFObject] = []
    var swiped: Int?
    
    var individualDistance = ""
    let locationManager = CLLocationManager()
    var videoUrl: String?
    var videoData: PFFile?
    var videoFilePath: String?
    var player: AVPlayer?
    var seenObjectIds: [String] = []
    var peeking: Bool?
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var noCardsImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var nahButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var likeitButton: UIButton!

    
    @IBOutlet weak var staticSavedLabel: UILabel!
    @IBOutlet weak var staticLabelView: UIView!
    @IBOutlet weak var savedDetailsButton: UIButton!
    @IBOutlet weak var savedDetailView: UIView!
    @IBOutlet weak var myAccountButton: UIButton!
    var centerXFactor: CGFloat = 2.0
    var centerYFactor: CGFloat = 3.8
    var frameXFactor: CGFloat = 10
    var frameYFactor: CGFloat = 10
    
    var playButton: UIButton?
    var swipedCard: PFObject?
    
    //var currentMainView: MainView!
    var mainViews: [MainView] = []
    //Current Lat and LONG
    var currLat : Double?
    var currLong: Double?
    var cardsWithDistanceChecked = [PFObject]()
    var currLocation = ""
    func newSettings(radiusChanged: Bool, cityChanged: Bool, radius: Int, newCity: String) {
        /*
        locationManager.delegate = self //sets the class as delegate for locationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //specifies the location accuracy
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() //starts receiving location updates from CoreLocation
 */
        
        //kolodaView.removeCardInIndexRange(1..<2, animated: false)
        
        print(kolodaView.countOfCards)
        kolodaView.delegate = self
        kolodaView.dataSource = self
        
        mainViews = []
        kolodaView.reloadData()
        kolodaView.resetCurrentCardIndex()
        
        //kolodaView.resetCurrentCardIndex()
        //reloadCards(radius, newCity: newCity)
        loadCards()
    }

    @IBAction func onX(sender: AnyObject) {
        if numInStack > 0 {
        if(mainViews[kolodaView.currentCardIndex].currentCard != nil)
        {
            //let currentCard = mainViews[kolodaView.currentCardIndex].currentCard
            //self.handleSwipe(.Left)
            kolodaView.swipe(SwipeResultDirection.Left)
            //swipeLeft(currentCard)
        }
    }
    }
    
    @IBAction func onLove(sender: AnyObject) {
        
        
        if numInStack > 0 {
        if(mainViews[kolodaView.currentCardIndex].currentCard != nil)
        {
            //let currentCard = mainViews[kolodaView.currentCardIndex].currentCard
            kolodaView.swipe(SwipeResultDirection.Right)
            //swipeRight(currentCard)
        }
    }
}
    @IBAction func onSave(sender: AnyObject) {
        if numInStack > 0 {
        if(mainViews[kolodaView.currentCardIndex].currentCard != nil)
        {
            //let currentCard = mainViews[kolodaView.currentCardIndex].currentCard
            kolodaView.swipe(SwipeResultDirection.Down)
            //swipeDown(currentCard)
        }
    }
    }
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        koloda.hidden = true
        let imageView = UIImageView()
        imageView.frame = kolodaView.frame
        let nomorecardsimage = UIImage(named: "NoCardsInYourRegion")
        imageView.image = nomorecardsimage
    }
    
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return UInt(mainViews.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        print(mainViews.count)
        if mainViews.count > 0 {
            /*
            if mainViews[Int(index)].currentCard["videoData"] != nil {
                //self.videoUrl = mainViews[Int(index)].currentCard["videoUrl"] as? String
                self.videoData = mainViews[Int(index)].currentCard["videoData"] as? PFFile
                //self.videoFilePath = mainViews[Int(index)].currentCard["videoFilePath"] as? String
                
                //let theplayer = mainViews[Int(index)].player
                let currentMainView = mainViews[Int(index)]
                let tap = UITapGestureRecognizer(target: mainViews[Int(index)], action: #selector(MainView.pauseVideo(_:)))
                tap.delegate = currentMainView
                currentMainView.userInteractionEnabled = true
                currentMainView.addGestureRecognizer(tap)
                
                let button = UIButton()
                button.frame = CGRectMake(150, 200, 80, 80)
                button.setBackgroundImage(UIImage(named: "playbutton"), forState: UIControlState.Normal)
                //button.backgroundColor = UIColor.blackColor()
                button.addTarget(self, action: #selector(self.playVideo(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                self.playButton = button
                self.playButton!.tag = 0
                //mainViews[Int(index)].addSubview(button)
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.showPlayButton), name: "ShowVideoButton", object: nil)
                self.view.insertSubview(self.playButton!, aboveSubview: self.kolodaView)
                //playVideoButton.hidden = false
            }*/
            return mainViews[Int(index)]
        }
        else {
            return UIView()
        }
        
    }
    
   
    
    func koloda(koloda: KolodaView, didShowCardAtIndex index: UInt) {
        
        if mainViews[Int(index)].currentCard["videoData"] != nil {
            //self.videoUrl = mainViews[Int(index)].currentCard["videoUrl"] as? String
            self.videoData = mainViews[Int(index)].currentCard["videoData"] as? PFFile
            //self.videoFilePath = mainViews[Int(index)].currentCard["videoFilePath"] as? String
            
            //let theplayer = mainViews[Int(index)].player
            let currentMainView = mainViews[Int(index)]
            let tap = UITapGestureRecognizer(target: mainViews[Int(index)], action: #selector(MainView.pauseVideo(_:)))
            tap.delegate = currentMainView
            currentMainView.userInteractionEnabled = true
            currentMainView.addGestureRecognizer(tap)
            
            
            
            let button = UIButton()
            button.frame = CGRectMake(150, 150, 80, 80)
            button.setBackgroundImage(UIImage(named: "playbutton"), forState: UIControlState.Normal)
            //button.backgroundColor = UIColor.blackColor()
            button.addTarget(self, action: #selector(self.playVideo(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.playButton = button
            mainViews[Int(index)].addSubview(button)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.showPlayButton), name: "ShowVideoButton", object: nil)
            
            //playVideoButton.hidden = false
        }
    }
    
    func showPlayButton() {
        self.playButton!.hidden = false
        print("showPlayButton() hidden: \(self.playButton!.hidden)")
    }
    
    
    func playVideo(sender: UIButton) {
        sender.hidden = true
        self.playButton!.hidden = true
        print("playVideo() hidden: \(self.playButton!.hidden)")
        //self.playButton!.hidden = true
        /*
        if let button = self.view.viewWithTag(0) {
            button.removeFromSuperview()
        }*/
        let currentMainView = self.mainViews[kolodaView.currentCardIndex]
        if currentMainView.player != nil {
            if currentMainView.player!.rate == 0 {
                currentMainView.player!.play()
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if(FBSDKAccessToken.currentAccessToken() != nil)
        {
            FBSDKAccessToken.refreshCurrentAccessToken({ (connection: FBSDKGraphRequestConnection!, object: AnyObject!, error: NSError!) in
                print(FBSDKAccessToken.currentAccessToken().hasGranted("user_friends"))
                if !FBSDKAccessToken.currentAccessToken().hasGranted("user_friends") {
                    let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                    loginManager.logInWithReadPermissions(["user_friends"], fromViewController: self, handler: { (response: FBSDKLoginManagerLoginResult!, error: NSError!) in
                        if error != nil {
                            print(error)
                        }
                    })
                }
            })
        }
        let navBar = navigationController!.navigationBar
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        navBar.translucent = true
        navigationController!.view.backgroundColor = UIColor.clearColor()
        
        /*
         navigationController!.view.backgroundColor = UIColor.clearColor()
         navigationController!.navigationBar.barTintColor = UIColor.clearColor()
         navigationController!.navigationBar.tintColor = UIColor.clearColor()*/
        
        //Put logo in nav bar
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
        imageView.contentMode = .ScaleAspectFit
        // 4
        let image = UIImage(named: "VentureBlackNavBarTitleView")
        imageView.image = image
        // 5
        navigationItem.titleView = imageView
        
        //self.navigationController!.navigationBar.layer.zPosition = -1;
        let user = PFUser.currentUser()
        user!.setObject([], forKey: "swiped")
        user!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if error != nil {
                print(error)
            }
        })
        
        
        if user!["swiped"] == nil {
            user!.setObject([], forKey: "swiped")
            user!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if error != nil {
                    print(error)
                }
            })
        }
        
        
        
        kolodaView.delegate = self
        kolodaView.dataSource = self
        
        self.staticLabelView.hidden = true
        
        noCardsImageView.hidden = true
        self.savedDetailView.hidden = true
        
        locationManager.delegate = self //sets the class as delegate for locationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //specifies the location accuracy
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() //starts receiving location updates from CoreLocation
        
        
        likesLabel.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
        distanceLabel.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
        myAccountButton.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
        myAccountButton.titleLabel!.text = "Saved"
        self.savedDetailsButton.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 13)
        self.staticSavedLabel.font = UIFont (name: "HelveticaNeue-Thin", size: 13)
        
        // show progress HUD
        ARSLineProgress.show()
        //ARSLineProgress.showSuccess()
        //MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    //Catch error if location manager fails
    override func viewWillAppear(animated: Bool) {
        
        //Set up for location controller
        super.viewWillAppear(animated)

    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        let currentMainView = mainViews[Int(index)]
        let transitionOptions: UIViewAnimationOptions = [.TransitionFlipFromRight]
        
        if currentMainView.frontView!.hidden {
            UIView.transitionWithView(currentMainView.backView!, duration: 0.3, options: transitionOptions, animations: {
                currentMainView.backView!.hidden = true
                }, completion: nil)
            
            UIView.transitionWithView(currentMainView.frontView!, duration: 0.3, options: transitionOptions, animations: {
                currentMainView.frontView!.hidden = false
                }, completion: nil)
            
        }
        else {
            UIView.transitionWithView(currentMainView.frontView!, duration: 0.3, options: transitionOptions, animations: {
                currentMainView.frontView!.hidden = true
                }, completion: nil)
            
            UIView.transitionWithView(currentMainView.backView!, duration: 0.3, options: transitionOptions, animations: {
                
                currentMainView.backView!.hidden = false
                }, completion: nil)
        }
    }
    
    
    
    func loadCards() {
        
        /*
         let userCardQuery = PFQuery(className: "UserCard")
         let username = PFUser.currentUser()!.username!
         userCardQuery.whereKey("userCardId", hasPrefix: username)
         userCardQuery.findObjectsInBackgroundWithBlock { (userCards: [PFObject]?, error: NSError?) in
         if userCards != nil {
         for userCard in userCards! {
         let card = userCard["card"] as! PFObject
         let objectId = card.objectId!
         self.seenObjectIds.append(objectId)
         }
         }
         }*/
        
        
        let user = PFUser.currentUser()
        print("num loaded; \(numLoaded)")
        let currentUser = PFUser.currentUser()
        let query = PFQuery(className: "Card")
        //query.whereKeyExists("videoData")
        //query.whereKeyDoesNotExist("videoData")
        query.orderByDescending("createdAt")
        //query.orderByDescending("likesCount")
        query.whereKey("objectId", notContainedIn: user!["swiped"] as! [String])
        print(user!["swiped"] as! [String])
        query.includeKey("author")
        query.skip = numLoaded
        query.limit = 10
        if (currentUser!["defaultCity"] != nil) {
            if currentUser!["defaultCity"] as! String != "" {
                query.whereKey("city", equalTo: currentUser!["defaultCity"])
                peeking = true
            }
            else {
                peeking = false
            }
        }
        else
        {
            currentUser?.setObject("", forKey: "defaultCity")
            currentUser?.saveInBackground()
            peeking = false
        }
        query.findObjectsInBackgroundWithBlock { (cards: [PFObject]?, error: NSError?) in
            if cards == nil {
                print(error)
            }
            else if cards!.count == 0 {
                print("no more")
                print(self.kolodaView.countOfCards)
                if self.numInStack == 0 {
                    ARSLineProgress.hide()
                    self.kolodaView.hidden = true
                    let imageView = UIImageView()
                    imageView.frame = self.kolodaView.frame
                    let nomorecardsimage = UIImage(named: "NoMorePicturesLarger")
                    imageView.image = nomorecardsimage
                    self.view.addSubview(imageView)
                }
                /*
                 let nomorecardsimage = UIImage(named: "NoCardsInYourRegion")
                 let lastView = LastView(
                 frame: CGRectMake(0, 0, self.view.frame.width - self.frameXFactor, self.view.frame.width - self.frameYFactor),
                 center: CGPoint(x: self.view.bounds.width / self.centerXFactor , y: self.view.bounds.height / self.centerYFactor),
                 image: nomorecardsimage!)
                 self.distanceLabel.text = ""
                 self.likesLabel.text = ""
                 self.view.insertSubview(lastView, atIndex: 0)
                 self.kolodaView.hidden = true*/
            }
            else if cards!.count > 0 {
                self.cards = cards!
                print(cards!.count)
                
                if currentUser!["radius"] != nil {
                    self.radiusInfo = currentUser!["radius"] as! Int
                }
                for card in cards! {
                    
                    //self.addCardToStack(card, distance: "0 mi")
                    self.checkDislikes(card)
                    let gotLat = card["latitude"] as! Double
                    let gotLong = card["longitude"] as! Double
                    //self.getDistance(self.currLat!, long1: self.currLong!, lat2: gotLat, long2: gotLong)
                    //Calculate distance using getDistance2 function
                    
                    self.getDistance2(self.currLat!, long1: self.currLong!, lat2: gotLat, long2: gotLong, completionHandler: { (distance: String?, error: NSError?) in
                        if (distance != nil) {
                            self.numLoaded += 1
                            var distanceStringArray = distance!.componentsSeparatedByString(" ")
                            if self.peeking! {
                                self.addCardToStack(card, distance: distance!)
                                self.numInRange += 1
                                self.kolodaView.reloadData()
                            }
                            else { //not peeking
                                if Double(self.radiusInfo) >= Double(distanceStringArray[0])!{
                                    print("added card")
                                    self.addCardToStack(card, distance: distance!)
                                    self.numInRange += 1
                                    self.kolodaView.reloadData()
                                }
                                else {
                                    print("not in range")
                                    self.numNotInRange += 1
                                }
                            }
                        } else
                        {
                            print("distance is nil")
                        }
                        
                        if (self.numNotInRange + self.numInRange) == cards!.count {
                            ARSLineProgress.hide()
                            //ARSLineProgress.showFail()
                            //MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                            if self.numInStack == 0 {
                                self.kolodaView.hidden = true
                                let imageView = UIImageView()
                                imageView.frame = self.kolodaView.frame
                                let nomorecardsimage = UIImage(named: "NoMorePicturesLarger")
                                imageView.image = nomorecardsimage
                                self.view.addSubview(imageView)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func reloadCards(radius: Int, newCity: String) {
        
        /*
        let userCardQuery = PFQuery(className: "UserCard")
        let username = PFUser.currentUser()!.username!
        userCardQuery.whereKey("userCardId", hasPrefix: username)
        userCardQuery.findObjectsInBackgroundWithBlock { (userCards: [PFObject]?, error: NSError?) in
            if userCards != nil {
                for userCard in userCards! {
                    let card = userCard["card"] as! PFObject
                    let objectId = card.objectId!
                    self.seenObjectIds.append(objectId)
                }
            }
        }*/
        
        
        let user = PFUser.currentUser()
        print("num loaded; \(numLoaded)")
        let currentUser = PFUser.currentUser()
        let query = PFQuery(className: "Card")
        //query.whereKeyExists("videoData")
        //query.whereKeyDoesNotExist("videoData")
        query.orderByDescending("createdAt")
        //query.orderByAscending("likesCount")
        query.whereKey("objectId", notContainedIn: user!["swiped"] as! [String])
        print(user!["swiped"] as! [String])
        query.includeKey("author")
        query.skip = numLoaded
        query.limit = 10
        
        if newCity != "" {
            query.whereKey("city", equalTo: currentUser!["defaultCity"])
            peeking = true

        }
        else {
            peeking = false
        }
        
        query.findObjectsInBackgroundWithBlock { (cards: [PFObject]?, error: NSError?) in
            if cards == nil {
                print(error)
            }
            else if cards!.count == 0 {
                print("no more")
                print(self.kolodaView.countOfCards)
                if self.numInStack == 0 {
                    ARSLineProgress.hide()
                    self.kolodaView.hidden = true
                    let imageView = UIImageView()
                    imageView.frame = self.kolodaView.frame
                    let nomorecardsimage = UIImage(named: "NoMorePicturesLarger")
                    imageView.image = nomorecardsimage
                    self.view.addSubview(imageView)
                }
                /*
                let nomorecardsimage = UIImage(named: "NoCardsInYourRegion")
                let lastView = LastView(
                    frame: CGRectMake(0, 0, self.view.frame.width - self.frameXFactor, self.view.frame.width - self.frameYFactor),
                    center: CGPoint(x: self.view.bounds.width / self.centerXFactor , y: self.view.bounds.height / self.centerYFactor),
                    image: nomorecardsimage!)
                self.distanceLabel.text = ""
                self.likesLabel.text = ""
                self.view.insertSubview(lastView, atIndex: 0)
                self.kolodaView.hidden = true*/
            }
            else if cards!.count > 0 {
                self.cards = cards!
                print(cards!.count)
                
                
                self.radiusInfo = radius as! Int
                
                for card in cards! {
                    
                    //self.addCardToStack(card, distance: "0 mi")
                    self.checkDislikes(card)
                    let gotLat = card["latitude"] as! Double
                    let gotLong = card["longitude"] as! Double
                    //self.getDistance(self.currLat!, long1: self.currLong!, lat2: gotLat, long2: gotLong)
                    //Calculate distance using getDistance2 function
                    
                    self.getDistance2(self.currLat!, long1: self.currLong!, lat2: gotLat, long2: gotLong, completionHandler: { (distance: String?, error: NSError?) in
                        if (distance != nil) {
                            self.numLoaded += 1
                            var distanceStringArray = distance!.componentsSeparatedByString(" ")
                            if self.peeking! {
                                self.addCardToStack(card, distance: distance!)
                                self.numInRange += 1
                                self.kolodaView.reloadData()
                            }
                            else { //not peeking
                                if Double(self.radiusInfo) >= Double(distanceStringArray[0])!{
                                    print("added card")
                                    self.addCardToStack(card, distance: distance!)
                                    self.numInRange += 1
                                    self.kolodaView.reloadData()
                                }
                                else {
                                    print("not in range")
                                    self.numNotInRange += 1
                                }
                            }
                        } else
                        {
                            print("distance is nil")
                        }
                        
                        if (self.numNotInRange + self.numInRange) == cards!.count {
                            ARSLineProgress.hide()
                            //ARSLineProgress.showFail()
                            //MBProgressHUD.hideHUDForView(self.view, animated: true)

                            if self.numInStack == 0 {
                                self.kolodaView.hidden = true
                                let imageView = UIImageView()
                                imageView.frame = self.kolodaView.frame
                                let nomorecardsimage = UIImage(named: "NoMorePicturesLarger")
                                imageView.image = nomorecardsimage
                                self.view.addSubview(imageView)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func kolodaShouldTransparentizeNextCard(koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(koloda: KolodaView, allowedDirectionsForIndex index: UInt) -> [SwipeResultDirection] {
        return [SwipeResultDirection.Left, SwipeResultDirection.Right, SwipeResultDirection.Down]
    }
    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        
        let currentCard = mainViews[Int(index)].currentCard
        let user = PFUser.currentUser()
        var swiped = user!["swiped"] as! [String]
        swiped.append(currentCard.objectId!)
        user!["swiped"] = swiped

        
        let date = NSDate()
        
        UserCard.newUserCard(PFUser.currentUser()!, card: currentCard, date: date)
        /*
        let addressArray = currentCard["addressArray"] as! [String]
        let address = addressArray[0]
        print(address)*/
        if mainViews[Int(index)].player != nil {
            //print(currentCard["videoUrl"])
            //self.playVideoButton.hidden = false
            mainViews[Int(index)].player!.pause()
            
        }
        self.swipedCard = currentCard
        if direction == SwipeResultDirection.Left {
            //kolodaView.swipe(SwipeResultDirection.Left)
            swipeLeft(currentCard)
        }
        else if direction == SwipeResultDirection.Right {
            //kolodaView.swipe(SwipeResultDirection.Right)
            swipeRight(currentCard)
        }
        else if direction == SwipeResultDirection.Down {
            //kolodaView.swipe(SwipeResultDirection.Down)
            swipeDown(currentCard)
            
        }
        
        numInStack -= 1
        /*
        if numInStack == 0 {
            self.kolodaView.hidden = true
            let imageView = UIImageView()
            imageView.frame = self.kolodaView.frame
            let nomorecardsimage = UIImage(named: "NoCardsInYourRegion")
            imageView.image = nomorecardsimage
            self.view.addSubview(imageView)
        }*/
        
        if numInStack < 5 {
            loadCards()
        }
        
        user!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if success {
                print("added to swiped")
                print("swiped count \(user!["swiped"].count)")
            }
            else {
                print(error)
            }
        }
    }
    
    func swipeDown(card: PFObject) {
        self.savedDetailView.hidden = false
        let user = PFUser.currentUser()
        if let userSaved = user![savedKey] as? [PFObject] {
            var savedCards = userSaved
            savedCards.append(card)
            user![savedKey] = savedCards
        }
        else {
            // in case the object wasn't set
            let save: [PFObject] = [card]
            user?.setObject(save, forKey: savedKey)
        }
        
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success {
                print("saved successfully")
                
                let date = NSDate()
                //let currentCard = self.mainViews[self.kolodaView.currentCardIndex].currentCard
                UserCard.newUserCard(PFUser.currentUser()!, card: card, date: date)
                self.addLocalNotification(card)
            }
            else {
                print(error)
            }
        })
    }
    
    func swipeRight(card: PFObject) {
        var likes = card["likesCount"] as! Int
        likes += 1
        card["likesCount"] = likes
        card.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success {
                print("likes count incremented")
            }
            else {
                print(error)
            }
        })
    }
    
    func swipeLeft(card: PFObject) {
        var dislikes = card["dislikesCount"] as! Int
        dislikes += 1
        card["dislikesCount"] = dislikes
        card.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success {
                print("dislikes count incremented")
            }
            else {
                print(error)
            }
        })
    }
    
    
    func addCardToStack(card: PFObject, distance: String) {
        let newView = MainView(
            frame: CGRectMake(0, 0, self.view.frame.width - self.frameXFactor, self.view.frame.width),
            center: CGPoint(x: self.view.bounds.width / self.centerXFactor, y: self.view.bounds.height / self.centerYFactor),
            card: card, distance: distance, lat: self.currLat!, long: self.currLong!)
        newView.layer.cornerRadius = newView.frame.height/30
        
        //newView.backgroundColor = UIColor.blackColor()
        //newView.transform = CGAffineTransformMakeRotation(-0.03)
        
        //self.mainViews.append(self.currentMainView)
        self.mainViews.append(newView)
        //print(self.mainViews.count)
        /*
         if currentMainView == nil {
         self.currentMainView = self.mainViews.last
         }*/
        numInStack += 1
        //numLoaded += 1
        //self.view.insertSubview(newView, atIndex: 0)
        //print("views: \(self.view.subviews.count)")
        //self.likesLabel.text = "\(card["likesCount"]) likes"
        //self.distanceLabel.text = "\(distance)"
        /*print(self.distanceData)
         if(self.distanceData != nil)
         {
         let rowsDict = self.distanceData!["rows"] as! NSDictionary
         let elementsDict = rowsDict["elements"] as! NSDictionary
         let distanceDict = elementsDict["distance"] as! NSDictionary
         
         self.distanceLabel.text = distanceDict.valueForKey("text") as! String
         }*/
        
        /*
         for mainView in self.mainViews {
         self.view.insertSubview(mainView, atIndex: 0)
         }*/
        
        //let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        //self.view.addGestureRecognizer(pan)
        //print("mainviews count \(self.mainViews.count)")
    }
    
    func addLocalNotification(card: PFObject) {
        //let user = PFUser.currentUser()
        let notification = UILocalNotification()
        
        let cardLat = card["latitude"] as! Double
        let cardLng = card["longitude"] as! Double
        
        //let addressArray = card["addressArray"] as! [String]
        //let address = addressArray[0]
        let location = card["location"] as! String
        notification.alertTitle = "Visit a saved location!"
        notification.alertBody = "You're 5 mi. from \(location)."
        notification.regionTriggersOnce = true
        let center = CLLocationCoordinate2DMake(cardLat, cardLng)
        notification.region = CLCircularRegion(center: center, radius: CLLocationDistance(METERS_PER_MILE * 5), identifier: "\(card.objectId!)")
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
    /*
     func handleSwipe(swipe: Swipe) {
     // Run the swipe animation
     self.currentMainView.swipe(swipe)
     let user = PFUser.currentUser()
     
     if !self.savedDetailView.hidden {
     self.savedDetailView.hidden = true
     }
     if swipe == .Down {
     self.savedDetailView.hidden = false
     let savedCard = self.currentMainView.currentCard
     if let userSaved = user![savedKey] as? [PFObject] {
     var savedCards = userSaved
     savedCards.append(savedCard)
     user![savedKey] = savedCards
     }
     else {
     // in case the object wasn't set
     let save: [PFObject] = [savedCard]
     user?.setObject(save, forKey: savedKey)
     }
     
     user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
     if success {
     print("saved successfully")
     
     let date = NSDate()
     UserCard.newUserCard(PFUser.currentUser()!, card: self.currentMainView.currentCard, date: date)
     self.addLocalNotification(self.currentMainView.currentCard)
     }
     else {
     print(error)
     }
     })
     
     
     }
     
     else if swipe == .Right {
     
     let currentCard = self.currentMainView.currentCard
     currentCard.fetchIfNeededInBackgroundWithBlock({ (currentCard: PFObject?, error: NSError?) in
     if error != nil {
     print(error)
     }
     else {
     var likes = currentCard!["likesCount"] as! Int
     likes += 1
     currentCard!["likesCount"] = likes
     currentCard?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
     if success {
     print("likes count incremented")
     }
     else {
     print(error)
     }
     })
     }
     })
     }
     else if swipe == .Left {
     let currentCard = self.currentMainView.currentCard
     currentCard.fetchIfNeededInBackgroundWithBlock({ (currentCard: PFObject?, error: NSError?) in
     if error != nil{
     print(error)
     }
     else {
     var dislikes = 0
     if(currentCard!["dislikesCount"] == nil)
     {
     //dislikes stays at 0
     }
     else
     {
     dislikes = currentCard!["dislikesCount"] as! Int
     }
     //Increment dislikesCount
     dislikes+=1
     currentCard!["dislikesCount"] = dislikes
     currentCard?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
     if(success)
     {
     print("dislike count incremented")
     }
     else
     {
     print(error)
     }
     })
     }
     
     })
     }
     //print("saved count \(self.saved.count)")
     
     // Handle when we have no more matches
     self.mainViews.removeAtIndex(self.mainViews.count - 1)
     numInStack -= 1
     
     if self.mainViews.count < 1 {
     
     let lastView = LastView(
     frame: CGRectMake(0, 0, self.view.frame.width - frameXFactor, self.view.frame.width - frameYFactor),
     center: CGPoint(x: self.view.bounds.width / centerXFactor, y: self.view.bounds.height / centerYFactor),
     image: UIImage())
     self.distanceLabel.text = ""
     self.likesLabel.text = ""
     self.view.insertSubview(lastView, atIndex: 0)
     
     return
     }
     else {
     
     // Set the new current question to the next one
     self.swipedCard = self.currentMainView.currentCard
     self.currentMainView = self.mainViews.last!
     let currentCard = self.currentMainView.currentCard
     if currentCard["videoUrl"] != nil {
     self.playVideoButton.hidden = false
     self.videoUrl = currentCard["videoUrl"] as? String
     
     }
     let likes = currentCard["likesCount"] as! Int
     if likes == 1 {
     self.likesLabel.text = "\(likes) like"
     }
     else {
     self.likesLabel.text = "\(likes) likes"
     }
     //self.getDistance(currentCard["latitude"] as! Double, long1: currentCard["longitude"] as! Double, lat2: currLat!, long2: currLong!)
     loadCards()
     }
     
     
     }*/
    /*
    @IBAction func playVideoButtonTapped(sender: AnyObject) {
        let currentMainView = self.mainViews[kolodaView.currentCardIndex]
        if currentMainView.player != nil {
            if currentMainView.player!.rate != 0 {
                currentMainView.player!.pause()
            }
            else {
                currentMainView.player!.play()
            }
            
        }
        
        /*
        if self.videoData != nil {
            /*
             let url = NSURL(string: self.videoUrl!)
             print(self.videoUrl)
             
             let player = AVPlayer(URL: url!)
             let playerLayer = AVPlayerLayer(player: player)
             playerLayer.frame = self.currentMainView.frame
             self.currentMainView.layer.addSublayer(playerLayer)
             player.play()*/
            /*
            print(self.videoUrl!)
            let defaultManager = NSFileManager()
            if defaultManager.fileExistsAtPath("assets-library://asset/asset.mov?id=736688AA-3C03-46B7-8536-39BD30CAC909&ext=mov") {
                print(true)
            }
            else {
                print(false)
            }*/
            
            
            self.videoData?.getDataInBackgroundWithBlock({ (videoData: NSData?, error: NSError?) in
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
                playerLayer.frame = self.mainViews[self.kolodaView.currentCardIndex].frame
                self.view.layer.addSublayer(playerLayer)
                self.player = player
                
                NSNotificationCenter.defaultCenter().addObserver(self,
                    selector: #selector(self.playerItemDidReachEnd(_:)),
                    name: AVPlayerItemDidPlayToEndTimeNotification,
                    object: player.currentItem)
                
                
                player.play()

                
                

            })
            
            
            
            //let url = NSURL(fileURLWithPath: videoFilePath)
            
            /*
            let asset = AVURLAsset(URL: NSURL(fileURLWithPath: self.videoUrl!))
            let item = AVPlayerItem(asset: asset)
            let player = AVPlayer(URL: NSURL(fileURLWithPath: "assets-library://asset/asset.mov?id=736688AA-3C03-46B7-8536-39BD30CAC909&ext=mov"))
            //let player = AVPlayer(playerItem: item)
            
            
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.view.frame = self.mainViews[kolodaView.currentCardIndex].frame
            if player.status == AVPlayerStatus.Failed {
                print("failed")
            }
            else if player.status == AVPlayerStatus.ReadyToPlay {
                print("ready to play")
            }
            else if player.status == AVPlayerStatus.Unknown {
                print("unknown")
            }
            print(player.currentItem)
            //self.addChildViewController(playerViewController)
            playerViewController.player!.play()
            
            self.presentViewController(playerViewController, animated: true) {
                
                //playerViewController.delegate = self
                
                playerViewController.showsPlaybackControls = true
                
            } */
            
        }*/
        
    }*/
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.player!.seekToTime(CMTimeMakeWithSeconds(0, 600))
        self.player!.play()
    }
    /*
     func handlePan(gesture: UIPanGestureRecognizer) {
     
     if self.mainViews.count - 1 < 0 {
     view.removeGestureRecognizer(gesture)
     }
     else {
     // Is this gesture state finished??
     if gesture.state == UIGestureRecognizerState.Ended {
     // Decide if we need to swipe off or return to center
     //let location = gesture.locationInView(self.view)
     if self.currentMainView.center.x / self.view.bounds.maxX > 0.75 {
     self.handleSwipe(.Right)
     
     }
     else if self.currentMainView.center.x / self.view.bounds.maxX < 0.25 {
     self.handleSwipe(.Left)
     
     }
     else if self.currentMainView.center.y / self.view.bounds.maxY > 0.5 {
     self.handleSwipe(.Down)
     
     }
     else {
     self.currentMainView.returnToCenter()
     }
     }
     let translation = gesture.translationInView(self.currentMainView)
     self.currentMainView.center = CGPoint(x: self.currentMainView!.center.x + translation.x, y: self.currentMainView!.center.y + translation.y)
     gesture.setTranslation(CGPointZero, inView: self.view)
     }
     }*/
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkDislikes(card: PFObject) {
        
        //Check if card's dislike count is lower than 80% of the total actions done on the card
        var likeCount = 0
        var dislikeCount = 0
        var totalActions = 0.0
        if(card["likeCount"] != nil)
        {
            print("um this should never happen")
            likeCount = card["likeCount"] as! Int
        }
        if(card["dislikeCount"] != nil)
        {
            dislikeCount = card["dislikeCount"] as! Int
        }
        totalActions = Double(likeCount + dislikeCount)
        if(totalActions < 30)
        {
            return
        }
        else if((Double(dislikeCount))/totalActions > 0.8)
        {
            card.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if(success)
                {
                    print("successfully deleted picture from database")
                }
                else{
                    print("error deleting picture from database: \(error)")
                }
            })
        }
        
    }
    
    
    func getDistance2(lat1: Double, long1: Double, lat2: Double, long2 : Double, completionHandler: (String?, NSError?) -> Void ) -> NSURLSessionTask {
        let apiKey = "AIzaSyBUiaoGh2MwU2HUPtYcGYZaXmNIHu0-kz0"
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(lat1),\(long1)&destinations=\(lat2),\(long2)&key=\(apiKey)")
        let urlSession = NSURLSession.sharedSession()
        
        _ = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task = urlSession.dataTaskWithURL(url!) { data, response, error -> Void in
            if error != nil {
                // If there is an error in the web request, print it to the console
                // println(error.localizedDescription)
                completionHandler(nil, error)
                return
            }
            else {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as? NSDictionary {
                    self.distanceData = responseDictionary
                    //print(self.distanceData)
                    let rowsDict = self.distanceData!.valueForKey("rows") as! [NSDictionary]
                    let rowsDictFirstRow = rowsDict[0]
                    let elementsDict = rowsDictFirstRow.valueForKey("elements") as! [NSDictionary]
                    let elementsFirstRow = elementsDict[0]
                    let distanceDict = elementsFirstRow.valueForKey("distance") as! NSDictionary
                    let distanceString = distanceDict.valueForKey("text") as! String
                    self.individualDistance = distanceString
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(distanceString, nil)
                    })
                    return
                }
            }
        }
        task.resume()
        return task
        
    }
    func returnDistance(distance: String) -> String
    {
        print("Returns: \(distance)")
        return distance
    }
    /*
     func getDistance(lat1: Double, long1: Double, lat2: Double, long2 : Double)  {
     let apiKey = "AIzaSyBUiaoGh2MwU2HUPtYcGYZaXmNIHu0-kz0"
     let request = NSURLRequest(
     URL: NSURL(string: "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(lat1),\(long1)&destinations=\(lat2),\(long2)&key=\(apiKey)")!,
     cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
     timeoutInterval: 10)
     
     let session = NSURLSession(
     configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
     delegate: nil,
     delegateQueue: NSOperationQueue.mainQueue()
     )
     
     let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
     
     if dataOrNil != nil {
     let data = dataOrNil
     if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
     data!, options:[]) as? NSDictionary {
     
     /*let array = response.objectForKey("array_key") as! NSArray
     for item: AnyObject in array {
     var arrayItem = String(_cocoaString: item as! NSDictionary)
     callbackArray.append(arrayItem)
     }
     callback(callbackArray) */
     self.distanceData = responseDictionary
     //print(self.distanceData)
     let rowsDict = self.distanceData!.valueForKey("rows") as! [NSDictionary]
     let rowsDictFirstRow = rowsDict[0]
     let elementsDict = rowsDictFirstRow.valueForKey("elements") as! [NSDictionary]
     let elementsFirstRow = elementsDict[0]
     let distanceDict = elementsFirstRow.valueForKey("distance") as! NSDictionary
     let distanceString = distanceDict.valueForKey("text")
     //self.distance = distanceString as! String
     //self.distanceLabel.text = distanceString as? String
     }
     }
     //print("Data isnt nil")
     
     
     })
     
     task.resume()
     }
     */
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    //If location is updated
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                self.displayLocationInfo(pm)
                
                
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    //Print out the location
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            
            //Pass into global currlat and long variables
            currLat = containsPlacemark.location!.coordinate.latitude
            currLong = containsPlacemark.location!.coordinate.longitude
            currLocation = ("\((containsPlacemark.locality)!), \((containsPlacemark.administrativeArea)!), \((containsPlacemark.country)!)")
            let user = PFUser.currentUser()
            user!.setObject(currLocation, forKey: "currLoc")
            user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if(success)
                {
                    print("Successfully saved currLocation in database")
                }
                else
                {
                    print("Error saving currLocation in database: \(error)")
                }
            })
            loads += 1
            //loadCards()
            if loads == 1 {
                print("initial load \(self.view.subviews.count)")
                loadCards()
            }
        }
        
    }
    
    func unDim() {
        dim(.Out, speed: dimSpeed)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "saveSegue" {
            let savedvc = segue.destinationViewController as! SavedViewController
            savedvc.currLat = self.currLat
            savedvc.currLong = self.currLong
            savedvc.distanceString = self.individualDistance
        }
        else if segue.identifier == "savedDetailSegue" {
            
            let detailVC = segue.destinationViewController as! ManagePageViewController
            detailVC.card = self.swipedCard
            detailVC.currLat = self.currLat
            detailVC.currLong = self.currLong
            // previous card?
            
            /*
             let commentViewController = segue.destinationViewController as! CommentViewController
             
             let button = sender as! UIButton
             let view = button.superview!
             let cell = view.superview as! PostCell
             
             let indexPath = feedView.indexPathForCell(cell)
             let post = posts![indexPath!.section]
             commentViewController.post = post
             */
        }
        else if segue.identifier == "settingsSegue" {
            let settingsVC = segue.destinationViewController as! SettingsViewController
            settingsVC.delegate = self
             dim(.In, alpha: dimLevel, speed: dimSpeed)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.unDim), name: "Undim", object: nil)
        }
    }
}





/*
import UIKit
import Parse
import ParseUI
import CoreLocation
import AFNetworking
import ParseFacebookUtilsV4
import MBProgressHUD
import AVKit
import AVFoundation
import Koloda

/*
enum Swipe {
    case Left
    case Right
    case Up
    case Down
}*/

class MainViewController: UIViewController, CLLocationManagerDelegate {
 
    var radiusInfo: Float = 50
 
    let savedKey: String = "savedCards"
 
    let METERS_PER_MILE = 1609.344
 
    var loads: Int = 0
 
    var numLoaded: Int = 0
    var numInStack: Int = 0
 
    var distanceData :NSDictionary?
 
    var distance = ""

    var cards: [PFObject]?
    var saved: [PFObject] = []
    var swiped: Int?
 
    var individualDistance = ""
    let locationManager = CLLocationManager()
    var videoUrl: String?
    @IBOutlet weak var pictureView: UIImageView!
 
    @IBOutlet weak var kolodaView: KolodaView!
 
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
 
    @IBOutlet weak var nahButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var likeitButton: UIButton!
 
    @IBOutlet weak var staticLabelView: UIView!
    @IBOutlet weak var savedDetailsButton: UIButton!
    @IBOutlet weak var savedDetailView: UIView!
    @IBOutlet weak var myAccountButton: UIButton!
    var centerXFactor: CGFloat = 2.0
    var centerYFactor: CGFloat = 2.5
    var frameXFactor: CGFloat = 10
    var frameYFactor: CGFloat = 10
 
    var swipedCard: PFObject?
 
    var currentMainView: MainView!
    var mainViews: [MainView] = []
    //Current Lat and LONG
    var currLat : Double?
    var currLong: Double?
    var cardsWithDistanceChecked = [PFObject]()
    var currLocation = ""
 
    /*
    @IBAction func onX(sender: AnyObject) {
        if(cards != nil)
        {
            self.handleSwipe(.Left)
        }
    }
 
    @IBAction func onLove(sender: AnyObject) {
        if(cards != nil)
        {
            self.handleSwipe(.Right)
        }
    }
    
    @IBAction func onSave(sender: AnyObject) {
        if(cards != nil)
        {
            self.handleSwipe(.Down)
        }
    }*/
    
    @IBAction func onX(sender: AnyObject) {
        if(mainViews[kolodaView.currentCardIndex].currentCard != nil)
        {
            let currentCard = mainViews[kolodaView.currentCardIndex].currentCard
            //self.handleSwipe(.Left)
            kolodaView.swipe(SwipeResultDirection.Left)
            swipeLeft(currentCard)
        }
    }
    
    @IBAction func onLove(sender: AnyObject) {
        if(mainViews[kolodaView.currentCardIndex].currentCard != nil)
        {
            let currentCard = mainViews[kolodaView.currentCardIndex].currentCard
            kolodaView.swipe(SwipeResultDirection.Right)
            swipeRight(currentCard)
        }
    }
    
    @IBAction func onSave(sender: AnyObject) {
        if(mainViews[kolodaView.currentCardIndex].currentCard != nil)
        {
            let currentCard = mainViews[kolodaView.currentCardIndex].currentCard
            kolodaView.swipe(SwipeResultDirection.Down)
            swipeDown(currentCard)
        }
    }
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        print("we out")
    }
    
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return UInt(mainViews.count)
        
        
    }
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        print(mainViews.count)
        if mainViews.count > 0 {
            return mainViews[Int(index)]
        }
        else {
            return UIView()
        }
        
    }
    
    //Catch error if location manager fails
        override func viewDidLoad() {
        self.playVideoButton.hidden = true
        self.staticLabelView.hidden = true
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
        //Set up for location controller
        super.viewDidLoad()
            
        self.savedDetailView.hidden = true
            
        locationManager.delegate = self //sets the class as delegate for locationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //specifies the location accuracy
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() //starts receiving location updates from CoreLocation
        /*
        FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "name"], HTTPMethod: "GET").startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, response: AnyObject!, error: NSError!) in
            if response != nil {
                print("no error")
                let dict = response as! NSDictionary
                let data = dict.valueForKey("data") as! NSArray
                let friend = data[0] as! NSDictionary
                print(friend)
            }
            else {
                print("error")
                print(error)
            }
        }*/
        nahButton.layer.masksToBounds = false
        nahButton.layer.cornerRadius = nahButton.frame.height/2
        nahButton.clipsToBounds = true
        nahButton.titleLabel!.font = UIFont (name: "Cochin-BoldItalic", size: 25)

        saveButton.layer.masksToBounds = false
        saveButton.layer.cornerRadius = saveButton.frame.height/2
        saveButton.clipsToBounds = true
        saveButton.titleLabel!.font = UIFont (name: "Cochin-BoldItalic", size: 25)
        
        likeitButton.layer.masksToBounds = false
        likeitButton.layer.cornerRadius = likeitButton.frame.height/2
        likeitButton.clipsToBounds = true
        likeitButton.titleLabel!.font = UIFont (name: "Cochin-BoldItalic", size: 25)
        
        likesLabel.font = UIFont (name: "BodoniSvtyTwoSCITCTT-Book", size: 20)
        distanceLabel.font = UIFont (name: "BodoniSvtyTwoSCITCTT-Book", size: 20)
        myAccountButton.titleLabel!.font = UIFont (name: "BodoniSvtyTwoSCITCTT-Book", size: 24)
        //MBProgressHUD.showHUDAddedTo(self.view, animated: true)

    }
    
    
    
    func loadCards() {
        print("num loaded; \(numLoaded)")
        let currentUser = PFUser.currentUser()
        let query = PFQuery(className: "Card")
        //query.orderByDescending("createdAt")
        query.orderByAscending("likesCount")
        query.includeKey("author")
        query.limit = 10
        query.skip = numLoaded

        if (currentUser!["defaultCity"] != nil) {
            if currentUser!["defaultCity"] as! String != "" {
                query.whereKey("city", equalTo: currentUser!["defaultCity"])
            }
        }
        query.findObjectsInBackgroundWithBlock { (cards: [PFObject]?, error: NSError?) in
            if cards == nil {
                print(error)
            }
            else if cards!.count == 0 {
                print("no more")
                
                let lastView = LastView(
                    frame: CGRectMake(0, 0, self.view.frame.width - self.frameXFactor, self.view.frame.width - self.frameYFactor),
                    center: CGPoint(x: self.view.bounds.width / self.centerXFactor, y: self.view.bounds.height / self.centerYFactor),
                    image: UIImage())
                self.distanceLabel.text = ""
                self.likesLabel.text = ""
                self.view.insertSubview(lastView, atIndex: 0)
            }
            else if cards!.count > 0 {
                self.cards = cards!
                if currentUser!["radius"] != nil {
                    self.radiusInfo = currentUser!["radius"] as! Float
                }
                for card in cards! {
                    self.checkDislikes(card)
                    let gotLat = card["latitude"] as! Double
                    let gotLong = card["longitude"] as! Double
                   // self.getDistance(self.currLat!, long1: self.currLong!, lat2: gotLat, long2: gotLong)
                    //Calculate distance using getDistance2 function
                    
                    self.getDistance2(self.currLat!, long1: self.currLong!, lat2: gotLat, long2: gotLong, completionHandler: { (distance: String?, error: NSError?) in
                        if (distance != nil) {
                            var distanceStringArray = distance!.componentsSeparatedByString(" ")
                            if Double(self.radiusInfo) >= Double(distanceStringArray[0])!{
                                print("added card")
                                self.addCardToStack(card, distance: distance!)
                                self.kolodaView.reloadData()

                            }
                        } else
                        {
                            print("out of range")
                        }
                    })
                }
            }
        }
            

        
        //MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    func kolodaShouldTransparentizeNextCard(koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(koloda: KolodaView, allowedDirectionsForIndex index: UInt) -> [SwipeResultDirection] {
        return [SwipeResultDirection.Left, SwipeResultDirection.Right, SwipeResultDirection.Down]
    }
    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        
        let currentCard = mainViews[Int(index)].currentCard
        self.swipedCard = currentCard
        if direction == SwipeResultDirection.Left {
            //kolodaView.swipe(SwipeResultDirection.Left)
            swipeLeft(currentCard)
        }
        else if direction == SwipeResultDirection.Right {
            //kolodaView.swipe(SwipeResultDirection.Right)
            swipeRight(currentCard)
        }
        else if direction == SwipeResultDirection.Down {
            //kolodaView.swipe(SwipeResultDirection.Down)
            swipeDown(currentCard)
            
        }
        
        numInStack -= 1
        print("numInStack: \(numInStack)")
        if numInStack == 5 {
            loadCards()
        }
        
    }
    
    func swipeDown(card: PFObject) {
        self.savedDetailView.hidden = false
        let user = PFUser.currentUser()
        if let userSaved = user![savedKey] as? [PFObject] {
            var savedCards = userSaved
            savedCards.append(card)
            user![savedKey] = savedCards
        }
        else {
            // in case the object wasn't set
            let save: [PFObject] = [card]
            user?.setObject(save, forKey: savedKey)
        }
        
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success {
                print("saved successfully")
                
                let date = NSDate()
                let currentCard = self.mainViews[self.kolodaView.currentCardIndex].currentCard
                UserCard.newUserCard(PFUser.currentUser()!, card: currentCard, date: date)
                self.addLocalNotification(currentCard)
            }
            else {
                print(error)
            }
        })
    }
    
    func swipeRight(card: PFObject) {
        var likes = card["likesCount"] as! Int
        likes += 1
        card["likesCount"] = likes
        card.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success {
                print("likes count incremented")
            }
            else {
                print(error)
            }
        })
    }
    
    func swipeLeft(card: PFObject) {
        var dislikes = card["dislikesCount"] as! Int
        dislikes += 1
        card["dislikesCount"] = dislikes
        card.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success {
                print("dislikes count incremented")
            }
            else {
                print(error)
            }
        })
    }

    
    func addCardToStack(card: PFObject, distance: String) {
        let newView = MainView(
            frame: CGRectMake(0, 0, self.view.frame.width - self.frameXFactor, self.view.frame.width - self.frameYFactor),
            center: CGPoint(x: self.view.bounds.width / self.centerXFactor, y: self.view.bounds.height / self.centerYFactor),
            card: card, distance: distance)
                //newView.transform = CGAffineTransformMakeRotation(-0.03)
        
        
        //self.mainViews.append(self.currentMainView)
        self.mainViews.append(newView)
        //self.mainViews.insert(newView, atIndex: 0)
        /*
        if currentMainView == nil {
            self.currentMainView = self.mainViews.last
        }*/
        numInStack += 1
        numLoaded += 1
        //self.view.insertSubview(newView, atIndex: 0)
        //print("views: \(self.view.subviews.count)")
        //self.likesLabel.text = "\(card["likesCount"]) likes"
        //self.distanceLabel.text = "\(distance)"
        /*print(self.distanceData)
         if(self.distanceData != nil)
         {
         let rowsDict = self.distanceData!["rows"] as! NSDictionary
         let elementsDict = rowsDict["elements"] as! NSDictionary
         let distanceDict = elementsDict["distance"] as! NSDictionary
         
         self.distanceLabel.text = distanceDict.valueForKey("text") as! String
         }*/
        
        /*
         for mainView in self.mainViews {
         self.view.insertSubview(mainView, atIndex: 0)
         }*/
        
        //let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        //self.view.addGestureRecognizer(pan)
        //print("mainviews count \(self.mainViews.count)")
    }
    
    func addLocalNotification(card: PFObject) {
        let notification = UILocalNotification()
        
        let cardLat = card["latitude"] as! Double
        let cardLng = card["longitude"] as! Double

        
        let addressArray = card["addressArray"] as! [String]
        let address = addressArray[0]
        notification.alertTitle = "Visit a saved location!"
        notification.alertBody = "You're 5 mi. from \(address)."
        notification.regionTriggersOnce = true
        let center = CLLocationCoordinate2DMake(cardLat, cardLng)
        notification.region = CLCircularRegion(center: center, radius: CLLocationDistance(METERS_PER_MILE * 5), identifier: "\(card.objectId!)")
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    /*
    
    func handleSwipe(swipe: Swipe) {
        // Run the swipe animation
        self.currentMainView.swipe(swipe)
        let user = PFUser.currentUser()
        
        if !self.savedDetailView.hidden {
            self.savedDetailView.hidden = true
        }
        if swipe == .Down {
            self.savedDetailView.hidden = false
            let savedCard = self.currentMainView.currentCard
            if let userSaved = user![savedKey] as? [PFObject] {
                var savedCards = userSaved
                savedCards.append(savedCard)
                user![savedKey] = savedCards
            }
            else {
                // in case the object wasn't set
                let save: [PFObject] = [savedCard]
                user?.setObject(save, forKey: savedKey)
            }
            
            user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if success {
                    print("saved successfully")
                    
                    let date = NSDate()
                    UserCard.newUserCard(PFUser.currentUser()!, card: self.currentMainView.currentCard, date: date)
                    self.addLocalNotification(self.currentMainView.currentCard)
                }
                else {
                    print(error)
                }
            })
            
            
        }
        
        else if swipe == .Right {

            let currentCard = self.currentMainView.currentCard
            currentCard.fetchIfNeededInBackgroundWithBlock({ (currentCard: PFObject?, error: NSError?) in
                if error != nil {
                    print(error)
                }
                else {
                    var likes = currentCard!["likesCount"] as! Int
                    likes += 1
                    currentCard!["likesCount"] = likes
                    currentCard?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                        if success {
                            print("likes count incremented")
                        }
                        else {
                            print(error)
                        }
                    })
                }
            })
        }
        else if swipe == .Left {
            let currentCard = self.currentMainView.currentCard
            currentCard.fetchIfNeededInBackgroundWithBlock({ (currentCard: PFObject?, error: NSError?) in
                if error != nil{
                    print(error)
                }
                else {
                    var dislikes = 0
                    if(currentCard!["dislikesCount"] == nil)
                    {
                        //dislikes stays at 0
                    }
                    else
                    {
                        dislikes = currentCard!["dislikesCount"] as! Int
                    }
                    //Increment dislikesCount
                    dislikes+=1
                    currentCard!["dislikesCount"] = dislikes
                    currentCard?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                        if(success)
                        {
                            print("dislike count incremented")
                        }
                        else
                        {
                            print(error)
                        }
                    })
                }
                
            })
        }
        //print("saved count \(self.saved.count)")
        
        // Handle when we have no more matches
        self.mainViews.removeAtIndex(self.mainViews.count - 1)
        numInStack -= 1
        
        if self.mainViews.count < 1 {
            
            let lastView = LastView(
                frame: CGRectMake(0, 0, self.view.frame.width - frameXFactor, self.view.frame.width - frameYFactor),
                center: CGPoint(x: self.view.bounds.width / centerXFactor, y: self.view.bounds.height / centerYFactor),
                image: UIImage())
            self.distanceLabel.text = ""
            self.likesLabel.text = ""
            self.view.insertSubview(lastView, atIndex: 0)
            
            return
        }
        else {
            
            // Set the new current question to the next one
            self.swipedCard = self.currentMainView.currentCard
            self.currentMainView = self.mainViews.last!
            let currentCard = self.currentMainView.currentCard
            if currentCard["videoUrl"] != nil {
                self.playVideoButton.hidden = false
                self.videoUrl = currentCard["videoUrl"] as? String
                
            }
            let likes = currentCard["likesCount"] as! Int
            if likes == 1 {
                self.likesLabel.text = "\(likes) like"
            }
            else {
                self.likesLabel.text = "\(likes) likes"
            }
            //self.getDistance(currentCard["latitude"] as! Double, long1: currentCard["longitude"] as! Double, lat2: currLat!, long2: currLong!)
            loadCards()
        }
        
        
    } */
    
    @IBAction func playVideoButtonTapped(sender: AnyObject) {
        
        if self.videoUrl != nil {
            /*
            let url = NSURL(string: self.videoUrl!)
            print(self.videoUrl)
            
            let player = AVPlayer(URL: url!)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.currentMainView.frame
            self.currentMainView.layer.addSublayer(playerLayer)
            player.play()*/
            
            print(self.videoUrl!)
            let player = AVPlayer(URL: NSURL(string: self.videoUrl!)!)
            
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.view.frame = self.currentMainView.frame
            //self.addChildViewController(playerViewController)
            playerViewController.player!.play()
            
            self.presentViewController(playerViewController, animated: true) {
                
                //playerViewController.delegate = self
                
                playerViewController.showsPlaybackControls = true
                
            }

        }
 
    }
    
    /*
    func handlePan(gesture: UIPanGestureRecognizer) {
        
        if self.mainViews.count - 1 < 0 {
            view.removeGestureRecognizer(gesture)
        }
        else {
        // Is this gesture state finished??
        if gesture.state == UIGestureRecognizerState.Ended {
            // Decide if we need to swipe off or return to center
            //let location = gesture.locationInView(self.view)
            if self.currentMainView.center.x / self.view.bounds.maxX > 0.75 {
                self.handleSwipe(.Right)
                
            }
            else if self.currentMainView.center.x / self.view.bounds.maxX < 0.25 {
                self.handleSwipe(.Left)
                
            }
            else if self.currentMainView.center.y / self.view.bounds.maxY > 0.5 {
                self.handleSwipe(.Down)
                
            }
            else {
                self.currentMainView.returnToCenter()
            }
        }
        let translation = gesture.translationInView(self.currentMainView)
        self.currentMainView.center = CGPoint(x: self.currentMainView!.center.x + translation.x, y: self.currentMainView!.center.y + translation.y)
        gesture.setTranslation(CGPointZero, inView: self.view)
        }
    }

*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkDislikes(card: PFObject) {
        
        //Check if card's dislike count is lower than 80% of the total actions done on the card
        var likeCount = 0
        var dislikeCount = 0
        var totalActions = 0.0
        if(card["likeCount"] != nil)
        {
            print("um this should never happen")
            likeCount = card["likeCount"] as! Int
        }
        if(card["dislikeCount"] != nil)
        {
            dislikeCount = card["dislikeCount"] as! Int
        }
        totalActions = Double(likeCount + dislikeCount)
        if(totalActions < 30)
        {
            return
        }
        else if((Double(dislikeCount))/totalActions > 0.8)
        {
            card.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if(success)
                {
                    print("successfully deleted picture from database")
                }
                else{
                    print("error deleting picture from database: \(error)")
                }
            })
        }
        
    }

    
    func getDistance2(lat1: Double, long1: Double, lat2: Double, long2 : Double, completionHandler: (String?, NSError?) -> Void ) -> NSURLSessionTask {
        let apiKey = "AIzaSyBUiaoGh2MwU2HUPtYcGYZaXmNIHu0-kz0"
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(lat1),\(long1)&destinations=\(lat2),\(long2)&key=\(apiKey)")
        let urlSession = NSURLSession.sharedSession()
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task = urlSession.dataTaskWithURL(url!) { data, response, error -> Void in
            if error != nil {
                // If there is an error in the web request, print it to the console
                // println(error.localizedDescription)
                completionHandler(nil, error)
                return
            }
            else {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data!, options:[]) as? NSDictionary {
                        self.distanceData = responseDictionary
                        //print(self.distanceData)
                        let rowsDict = self.distanceData!.valueForKey("rows") as! [NSDictionary]
                        let rowsDictFirstRow = rowsDict[0]
                        let elementsDict = rowsDictFirstRow.valueForKey("elements") as! [NSDictionary]
                        let elementsFirstRow = elementsDict[0]
                        let distanceDict = elementsFirstRow.valueForKey("distance") as! NSDictionary
                        let distanceString = distanceDict.valueForKey("text") as! String
                        self.individualDistance = distanceString
                        dispatch_async(dispatch_get_main_queue(), { 
                            completionHandler(distanceString, nil)
                        })
                        return
                    }
                
                //print("Data isnt nil")
                
            }
        }
        task.resume()
        return task
        
    }
    func returnDistance(distance: String) -> String
    {
        print("Returns: \(distance)")
        return distance
    }
    /*
    func getDistance(lat1: Double, long1: Double, lat2: Double, long2 : Double)  {
        let apiKey = "AIzaSyBUiaoGh2MwU2HUPtYcGYZaXmNIHu0-kz0"
        let request = NSURLRequest(
            URL: NSURL(string: "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(lat1),\(long1)&destinations=\(lat2),\(long2)&key=\(apiKey)")!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            
                    if dataOrNil != nil {
                    let data = dataOrNil
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data!, options:[]) as? NSDictionary {
                        
                        /*let array = response.objectForKey("array_key") as! NSArray
                         for item: AnyObject in array {
                         var arrayItem = String(_cocoaString: item as! NSDictionary)
                         callbackArray.append(arrayItem)
                         }
                         callback(callbackArray) */
                        self.distanceData = responseDictionary
                        //print(self.distanceData)
                        let rowsDict = self.distanceData!.valueForKey("rows") as! [NSDictionary]
                        let rowsDictFirstRow = rowsDict[0]
                        let elementsDict = rowsDictFirstRow.valueForKey("elements") as! [NSDictionary]
                        let elementsFirstRow = elementsDict[0]
                        let distanceDict = elementsFirstRow.valueForKey("distance") as! NSDictionary
                        let distanceString = distanceDict.valueForKey("text")
                        //self.distance = distanceString as! String
                        //self.distanceLabel.text = distanceString as? String
                    }
                        }
            //print("Data isnt nil")
                
            
        })
        
        task.resume()
    }
 */
 
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    //If location is updated
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                self.displayLocationInfo(pm)
                
                
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    //Print out the location
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            
            //Pass into global currlat and long variables
            currLat = containsPlacemark.location!.coordinate.latitude
            currLong = containsPlacemark.location!.coordinate.longitude
            currLocation = ("\((containsPlacemark.locality)!), \((containsPlacemark.administrativeArea)!), \((containsPlacemark.country)!)")
            let user = PFUser.currentUser()
            user!.setObject(currLocation, forKey: "currLoc")
            user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if(success)
                {
                    print("Successfully saved currLocation in database")
                }
                else
                {
                    print("Error saving currLocation in database: \(error)")
                }
            })
            loads += 1
            //loadCards()
            if loads == 1 {
                print("initial load \(self.view.subviews.count)")
                loadCards()
            }
        }
        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "savedSegue" {
            let savedvc = segue.destinationViewController as! SavedViewController
            savedvc.currLat = self.currLat
            savedvc.currLong = self.currLong
            savedvc.distanceString = self.individualDistance
        }
        else if segue.identifier == "savedDetailSegue" {
            
            let detailVC = segue.destinationViewController as! DetailViewController
            detailVC.card = self.swipedCard
            detailVC.currLat = self.currLat
            detailVC.currLong = self.currLong
            // previous card?
            
            /*
             let commentViewController = segue.destinationViewController as! CommentViewController
             
             let button = sender as! UIButton
             let view = button.superview!
             let cell = view.superview as! PostCell
             
             let indexPath = feedView.indexPathForCell(cell)
             let post = posts![indexPath!.section]
             commentViewController.post = post
            */
        }
        else if segue.identifier == "playVideoSegue" {
            let videoVC = segue.destinationViewController as! VideoViewController
            videoVC.videoURL = self.videoUrl
        }
    }


}*/
