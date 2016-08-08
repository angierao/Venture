//
//  TWOViewController.swift
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

class TWOViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var cardPicture: UIImageView!
    @IBOutlet weak var gradientView2: UIView!
    @IBOutlet weak var reviewsTableView: UITableView!
    
    
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var picturesLabel: UILabel!
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        picturesLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        
        //Set up for photocollection view
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        venuePhotos = []
        getVenueInfo()

        //Set up for table view
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        
        reviews = card!["reviews"] as? [PFObject]
        
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
        gradient.frame = gradientView2.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        gradient.locations = [0.0, 0.58]
        gradientView2.layer.addSublayer(gradient)
    }
    
    //Venue Photos stuff
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let venuePhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCollectionCell", forIndexPath: indexPath) as! PhotosCollectionViewCell
        venuePhotoForIndexPath(indexPath, cell: venuePhotoCell)
        //venuePhotoCell.venuePhotoImage =
        /*let backgroundView: UIImageView = UIImageView(image: UIImage(named: "savedPlaceholder"))
        backgroundView.frame = CGRect(x: 0, y: 0, width: 100, height: 200)*/
        //venuePhotoCell.backgroundColor = UIColor.clearColor()
        //venuePhotoCell.backgroundView?.addSubview(backgroundView)
        return venuePhotoCell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.venuePhotos?.count ?? 0

    }
    func venuePhotoForIndexPath(indexPath: NSIndexPath, cell: PhotosCollectionViewCell) {
        cell.venuePhotoImage.image = UIImage(named: "savedPlaceHolder")
        let urlString = self.venuePhotos![indexPath.row]
        //print(urlString)
        let url = NSURL(string: urlString)
        //print("THA URL: \(url)")
        if url != nil {
            cell.venuePhotoImage.setImageWithURL(url!, placeholderImage: UIImage(named: "savedPlaceholder"))
        }
    }

    
    //Comments table view
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
                reviewCell.reviewLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
                let author = review!["author"] as! PFUser
                author.fetchInBackgroundWithBlock({ (user: PFObject?, error: NSError?) in
                    if user != nil {
                        let imageFile = author["profileImage"] as! PFFile
                        let firstname = author["firstName"] as! String
                        let lastname = author["lastName"] as! String
                        reviewCell.nameLabel.text = "\(firstname) \(lastname)"
                        
                        imageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
                            if data != nil {
                                let image = UIImage(data: data!)
                                reviewCell.profPicView.image = image
                                reviewCell.profPicView.layer.cornerRadius = reviewCell.profPicView.frame.height/2
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
                        //self.hoursLabel.text = timeTable
                    } else {
                        //self.hoursLabel.text = "Hours not available"
                    }
                    
                } else {
                    //self.hoursLabel.text = "Hours: It's high noon"
                }
                /*if let websiteUrlString = self.venue?.url {
                 self.url = websiteUrlString
                 
                 } else {
                 self.url = "no url"
                 } */
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
