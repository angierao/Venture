//
//  SimilarDetailViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/26/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse 

class SimilarDetailViewController: UIViewController {

    @IBOutlet weak var similarImage: UIImageView!
    var simImage : UIImage?
    var simCard : PFObject?
    let savedKey: String = "savedCards"
    let METERS_PER_MILE = 1609.344


    override func viewDidLoad() {
        super.viewDidLoad()
        similarImage.image = simImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissTouched(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func previewActionItems() -> [UIPreviewActionItem] {
        
        let likeAction = UIPreviewAction(title: "Like", style: .Default) { (action, viewController) -> Void in
            self.like()
        }
        let dislikeAction = UIPreviewAction(title: "Dislike", style: .Default) { (action, viewController) -> Void in
            self.dislike()
        }
        let saveAction = UIPreviewAction(title: "Save", style: .Default) { (action, viewController) -> Void in
            self.save()
        }
        
        let deleteAction = UIPreviewAction(title: "Cancel", style: .Destructive) { (action, viewController) -> Void in
            print("Cancelled")
        }
        
        return [likeAction, dislikeAction, saveAction, deleteAction]
        
    }
    func save()
    {
        let user = PFUser.currentUser()
        if let userSaved = user![savedKey] as? [PFObject] {
            var savedCards = userSaved
            savedCards.append(simCard!)
            user![savedKey] = savedCards
        }
        else {
            // in case the object wasn't set
            let save: [PFObject] = [simCard!]
            user?.setObject(save, forKey: savedKey)
        }
        
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success {
                print("saved successfully")
                
                let date = NSDate()
                UserCard.newUserCard(PFUser.currentUser()!, card: self.simCard!, date: date)
                self.addLocalNotification(self.simCard!)
            }
            else {
                print(error)
            }
        })

    }
    func like()
    {
        var likes = simCard!["likesCount"] as! Int
        likes += 1
        simCard!["likesCount"] = likes
        simCard!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success {
                print("likes count incremented")
            }
            else {
                print(error)
            }
        })

    }
    func dislike()
    {
        var dislikes = simCard!["dislikesCount"] as! Int
        dislikes += 1
        simCard!["dislikesCount"] = dislikes
        simCard!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success {
                print("dislikes count incremented")
            }
            else {
                print(error)
            }
        })

    }
    func addLocalNotification(card: PFObject) {
        //let user = PFUser.currentUser()
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


}
