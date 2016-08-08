//
//  AccountViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/5/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

protocol AccountSettingsDelegate {
    func userSetRadius(radius: Float)
}
class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let MAX_RADIUS: Float = 100.0
    let MAX_NOTIFICATION_RADIUS: Float = 10.0
    let METERS_PER_MILE = 1609.344
    
    @IBOutlet weak var notificationRadiusLabel: UILabel!
    @IBOutlet weak var notificationRadiusSlider: UISlider!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var applyChangesButton: UIButton!
    @IBOutlet weak var radiusLabelTitle: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var chooseCityButton: UIButton!
    @IBOutlet weak var useCurrLocButton: UIButton!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var profilePicImageView: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var promptButtonPFPic: UIButton!
    @IBOutlet weak var notificationRadiusTitleLabel: UILabel!
    let currUser = PFUser.currentUser()
    var radius: Int?
    var notificationRadius: Int?
    
    var radiusDidChange: Bool = false
    var notificationRadiusDidChange: Bool = false
    var delegate:AccountSettingsDelegate? = nil
    var profileImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.currUser!["radius"] != nil {
            //print("radius is: \(self.currUser!["radius"])")
            
            self.radius = Int(self.currUser!["radius"] as! Float)
            self.radiusLabel.text = String(radius!)
            let radiusSliderValue = Float(self.radius!) / MAX_RADIUS
            self.radiusSlider.setValue(radiusSliderValue, animated: true)
        }
        
        
        if self.currUser!["notificationRadius"] != nil {
            self.notificationRadius = Int(self.currUser!["notificationRadius"] as! Float)
            self.notificationRadiusLabel.text = String(notificationRadius!)
            let notificationRadiusSliderValue = Float(self.notificationRadius!) / MAX_NOTIFICATION_RADIUS
            self.notificationRadiusSlider.setValue(notificationRadiusSliderValue, animated: true)
            
        }
        
        //Figure out if there's a profile picture saved already:
        let currUser = PFUser.currentUser()
        if(currUser!["profileImage"] == nil)
        {
            promptButtonPFPic.hidden = false
            promptButtonPFPic.titleLabel!.font = UIFont (name: "HelveticaNeue", size: 16)
            promptButtonPFPic.layer.masksToBounds = false
            promptButtonPFPic.layer.cornerRadius = promptButtonPFPic.frame.height/2
            promptButtonPFPic.clipsToBounds = true
        }
        else
        {
            promptButtonPFPic.hidden = true
            let profilePicFile = currUser!["profileImage"] as! PFFile
            profilePicImageView.file = profilePicFile
            profilePicImageView.loadInBackground()
            
            profilePicImageView.layer.masksToBounds = false
            profilePicImageView.layer.cornerRadius = profilePicImageView.frame.height/2
            profilePicImageView.clipsToBounds = true
            
        }
        //Set name label
        usernameLabel.text = "\(currUser!["firstName"]) \(currUser!["lastName"])"
        settingsLabel.font = UIFont (name: "HelveticaNeue", size: 28)
        logoutButton.titleLabel!.font = UIFont (name: "HelveticaNeue", size: 32)
        useCurrLocButton.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 14)
        chooseCityButton.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 15)
        radiusLabelTitle.font = UIFont (name: "HelveticaNeue", size: 18)
        radiusLabel.font = UIFont (name: "HelveticaNeue", size: 16)
        applyChangesButton.titleLabel!.font = UIFont (name: "HelveticaNeue", size: 14)
        usernameLabel.font = UIFont (name: "HelveticaNeue", size: 20)
        notificationRadiusTitleLabel.font = UIFont (name: "HelveticaNeue", size: 18)
        notificationRadiusLabel.font = UIFont (name: "HelveticaNeue", size: 16)

    }

    @IBAction func promptButtonPFPicTapped(sender: AnyObject) {
        //Alert w/ two options: Use camera for profile pic or use photolibrary
        self.alert()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        profileImage = editedImage
        
        currUser?.setObject(getPFFileFromImage(profileImage)!, forKey: "profileImage")
        currUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if(success)
            {
                print("Success, saved profile picture")
            }
            else
            {
                print("Error saving profile picture: \(error)")
            }
        })
        // Do something with the images (based on your use case)
        profilePicImageView.image = editedImage
        profilePicImageView.layer.masksToBounds = false
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.height/2
        profilePicImageView.clipsToBounds = true
        //Hide the button
        promptButtonPFPic.hidden = true
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }


    //Use camera for profile picture:
    func uploadProfilePicCamera() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.Camera
    }
    //Use PhotoLibrary for profile picture:
    func uploadProfilePicPhotoLibrary()
    {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    
    self.presentViewController(vc, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onLogOut(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            self.performSegueWithIdentifier("logOutSegue", sender: nil)
        }
    }

    @IBAction func onNotificationRadiusChange(sender: AnyObject) {
        self.notificationRadius = Int(self.notificationRadiusSlider.value * MAX_NOTIFICATION_RADIUS)
        self.notificationRadiusLabel.text = String(notificationRadius!)
        self.notificationRadiusDidChange = true
    }
    
    @IBAction func onRadiusChange(sender: AnyObject) {
        
        self.radius = Int(self.radiusSlider.value * MAX_RADIUS)
        self.radiusLabel.text = String(radius!)
        self.radiusDidChange = true
    }
    
    @IBAction func onApplyChanges(sender: AnyObject) {
    /*
            let currUser = PFUser.currentUser()
            currUser?.setObject(radius!, forKey: "radius")
            currUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in if success {
                print(success)
            } else {
                print("NOOOOOOOOOO")
                print(error?.localizedDescription)
                // handle error
                }
            })*/
        }
    
    
    override func viewWillDisappear(animated: Bool) {
        if self.radiusDidChange {
            if currUser!["radius"] != nil {
                currUser!["radius"] = self.radius
            }
            else {
                currUser!.setObject(self.radius!, forKey: "radius")
            }
        }
        
        if self.notificationRadiusDidChange {
            if currUser!["notificationRadius"] != nil {
                currUser!["notificationRadius"] = self.notificationRadius
            }
            else {
                currUser!.setObject(self.notificationRadius!, forKey: "notificationRadius")
            }
            
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { 
                self.updateNotifications()
            })
            
        }
        
        currUser!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if error != nil {
                print(error)
            }
            else {
                print("changes saved")
            }
        }
       
    }
    
    func updateNotifications() {
        
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.region != nil {
                    let objectId = notification.region!.identifier
                    let query = PFQuery(className: "Card")
                    query.getObjectInBackgroundWithId(objectId, block: { (card: PFObject?, error: NSError?) in
                        if card != nil {
                            let latitude = card!["latitude"] as! Double
                            let longitude = card!["longitude"] as! Double
                            let newNotification = UILocalNotification()
                            let center = CLLocationCoordinate2DMake(latitude, longitude)
                            newNotification.region = CLCircularRegion(center: center, radius: CLLocationDistance(Double(self.notificationRadius!) * self.METERS_PER_MILE), identifier: "\(objectId)")
                            newNotification.alertTitle = "You're close to a saved location!"
                            let addressArray = card!["addressArray"] as! [String]
                            newNotification.alertBody = "You're \(self.notificationRadius!) mi. from \(addressArray[0])."
                            print(notification)
                            UIApplication.sharedApplication().cancelLocalNotification(notification)
                            print(newNotification)
                            UIApplication.sharedApplication().scheduleLocalNotification(newNotification)

                        }
                        else {
                            print(error)
                        }
                        
                        
                    })
                }
            }
    }
    
    @IBAction func currLocationTapped(sender: AnyObject) {
        currUser!["defaultCity"] = ""
        currUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success {
                let alertControlLocal = UIAlertController(title: "Success", message: "Now using your location for current city", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Okay", style: .Default) { (action) in
                    
                }
                alertControlLocal.addAction(okAction)
                self.presentViewController(alertControlLocal, animated: true, completion: nil)

            } else {
                print(error?.localizedDescription)
                // handle error
            }
    })
    }
    func alert () {
        let alertController = UIAlertController(title: "Profile Picture", message: "Upload from: ", preferredStyle: .Alert)
        let CameraAction = UIAlertAction(title: "Camera", style: .Default) { (action) in
                self.uploadProfilePicCamera()
        }
        let PhotoLibAction = UIAlertAction(title: "Photo Library", style: .Default) {(action) in
            self.uploadProfilePicPhotoLibrary()
        }
        alertController.addAction(CameraAction)
        alertController.addAction(PhotoLibAction)
        self.presentViewController(alertController, animated: true) {}
    }

    
}
