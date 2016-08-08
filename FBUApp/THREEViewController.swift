//
//  THREEViewController.swift
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

class THREEViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

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

    
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var friendCollectionView: UICollectionView!
    @IBOutlet weak var gradientView3: UIView!
    @IBOutlet weak var cardPicture: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        friendPics = []
        self.friendsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        //Setup for friends collection view
        friendCollectionView.delegate = self
        friendCollectionView.dataSource = self
        
        //Fill the friends
        populateFriends()

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
        gradient.frame = gradientView3.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        gradient.locations = [0.0, 0.58]
        
        gradientView3.layer.addSublayer(gradient)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.friendPics?.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let friendCell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        friendForIndexPath(indexPath, cell: friendCell)
        return friendCell
    }
    
    func friendForIndexPath(indexPath: NSIndexPath, cell: FriendCell) {
        let pic = self.friendPics![indexPath.row]
        let backImage = UIImage(named: "savedPlaceholder")
        cell.friendView.image = backImage

        pic.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) in
            if data != nil {
                let image = UIImage(data: data!)
                cell.friendView.image = image
                cell.friendView.layer.cornerRadius = cell.friendView.frame.height/2
                cell.friendView.clipsToBounds = true
            }
        }
        
    }
    
    func populateFriends() {
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
        
        FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields" : "name"], HTTPMethod: "GET").startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, response: AnyObject!, error: NSError!) in
            if response != nil {
                let dict = response as! NSDictionary
                let allFriends = dict.valueForKey("data") as! NSArray
                for friend in allFriends {
                    print(allFriends.count)
                    //print(friend)
                    let dict = friend as! NSDictionary
                    let fbId = dict["id"]
                    print(fbId)
                    //query!.whereKey("fbId", equalTo: fbId)
                    //query!.whereKeyExists("fbId")
                    
                    //query?.whereKey("fbId", hasPrefix: fbId)
                    let query = PFUser.query()
                    //query!.whereKeyExists("fbId")
                    query!.whereKey("fbId", containedIn: [fbId!])
                    query!.findObjectsInBackgroundWithBlock({ (friends: [PFObject]?, error: NSError?) in
                        if friends != nil {
                            print(friends)
                            //bdncktlglegkekkbcghhdeetncfgerrlprint(self.card)
                            let friend = friends![0]
                            friend.fetchIfNeededInBackgroundWithBlock({ (friend: PFObject?, error: NSError?) in
                                if friend != nil {
                                    //print(friend)
                                    let saved = friend!["savedCards"] as! [PFObject]
                                    //print(saved)
                                    let objectId = self.card!.objectId
                                    
                                    for card in saved {
                                        print(card.objectId)
                                        print(objectId)
                                        if card.objectId == objectId {
                                            print("same")
                                            let imageFile = friend!["profileImage"] as! PFFile
                                            self.friendPics?.append(imageFile)
                                            print(self.friendPics?.count)
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
