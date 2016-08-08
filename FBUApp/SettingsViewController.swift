//
//  SettingsViewController.swift
//  FBUApp
//
//  Created by Angeline Rao on 7/28/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import Parse
import ParseUI
import UIKit
import EFCircularSlider

enum Direction { case In, Out }

protocol Dimmable { }

extension Dimmable where Self: UIViewController {
    
    func dim(direction: Direction, color: UIColor = UIColor.blackColor(), alpha: CGFloat = 0.0, speed: Double = 0.0) {
        
        switch direction {
        case .In:
            
            // Create and add a dim view
            let dimView = UIView(frame: view.frame)
            dimView.backgroundColor = color
            dimView.alpha = 0.0
            view.addSubview(dimView)
            
            //self.navigationController!.view.addSubview(dimView)
            
            // Deal with Auto Layout
            dimView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
            
            // Animate alpha (the actual "dimming" effect)
            UIView.animateWithDuration(speed) { () -> Void in
                dimView.alpha = alpha
            }
            
        case .Out:
            UIView.animateWithDuration(speed, animations: { () -> Void in
                self.view.subviews.last?.alpha = alpha ?? 0
                }, completion: { (complete) -> Void in
                    self.view.subviews.last?.removeFromSuperview()
            })
        }
    }
}

protocol SettingsViewControllerDelegate : class {
    func newSettings(radiusChanged: Bool, cityChanged: Bool, radius: Int, newCity: String)
}

class SettingsViewController: UIViewController, CitiesViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var radiusLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var staticSettingsLabel: UILabel!
    @IBOutlet weak var staticMilesLabel: UILabel!
    @IBOutlet weak var staticCurrentLocationLabel: UILabel!
    @IBOutlet weak var peekButton: UIButton!
    @IBOutlet weak var staticCityLabel: UILabel!
    @IBOutlet weak var staticRadiusLabel: UILabel!
    @IBOutlet weak var currentLocationSwitch: UISwitch!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var profilePicImageView: PFImageView!
    @IBOutlet weak var promptButtonPFPic: UIButton!
    weak var delegate : SettingsViewControllerDelegate!

    var radiusChanged: Bool?
    var cityChanged: Bool?
    let currUser = PFUser.currentUser()
    
    var newRadius: Int?
    var newCity: Double?
    var profileImage : UIImage?

    @IBAction func logOutTapped(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            if error == nil {
                self.performSegueWithIdentifier("logOutSegue", sender: nil)
            }
        }
    }
    //IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var backgroundView: UIImageView!
    //@IBOutlet weak var currentLocation: UIButton!
    var circularSlider: EFCircularSlider?
    
    @IBAction func closeSettings(sender: AnyObject) {
        
        print(locationLabel.text)
        if !currentLocationSwitch.on && locationLabel.text == "None" {
            let alertControlLocal = UIAlertController(title: "Error", message: "Choose a city", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Okay", style: .Default) { (action) in
                
            }
            alertControlLocal.addAction(okAction)
            self.presentViewController(alertControlLocal, animated: true, completion: nil)
        }
        else {
            delegate.newSettings(true, cityChanged: true, radius: 0, newCity: "")
            dismissViewControllerAnimated(true, completion: nil)
            
            let currentUser = PFUser.currentUser()
            
            if currentUser!["radius"] != nil {
                currentUser!["radius"] = self.circularSlider!.currentValue
            }
            else {
                currentUser!.setObject(self.circularSlider!.currentValue, forKey: "radius")
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("Undim", object: nil)
            
            currentUser!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
                if error != nil {
                    print(error)
                }
            }
        }
        
        
    }
    
    @IBOutlet weak var locationLabel: UILabel!
    func switchChanged(sender: UISwitch) {
        if sender.on {
            self.staticCityLabel.hidden = true
            self.peekButton.hidden = true
            self.locationLabel.hidden = true
            
            self.circularSlider!.hidden = false
            self.radiusLabel.hidden = false
            self.staticRadiusLabel.hidden = false
            self.staticMilesLabel.hidden = false
            
            let currUser = PFUser.currentUser()
            //locationLabel.text = "Current Location"
            currUser!["defaultCity"] = ""
            currUser!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    /*
                    let alertControlLocal = UIAlertController(title: "Success", message: "Now using your location for current city", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "Okay", style: .Default) { (action) in
                        
                    }
                    alertControlLocal.addAction(okAction)
                    self.presentViewController(alertControlLocal, animated: true, completion: nil)*/
                    
                } else {
                    print(error?.localizedDescription)
                    // handle error
                    
                    let alertControlLocal = UIAlertController(title: "Error", message: "Unable to access your location", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "Okay", style: .Default) { (action) in
                        
                    }
                    alertControlLocal.addAction(okAction)
                    self.presentViewController(alertControlLocal, animated: true, completion: nil)
                }
            })
        }
        else {
            self.circularSlider!.hidden = true
            self.radiusLabel.hidden = true
            self.staticRadiusLabel.hidden = true
            self.staticMilesLabel.hidden = true
            
            self.peekButton.hidden = false
            self.staticCityLabel.hidden = false
            self.locationLabel.hidden = false
            
            self.performSegueWithIdentifier("citySearchSegue", sender: nil)
        }
    }
    
    func initializeCircularSlider() {
        let circularSlider = EFCircularSlider(frame: CGRectMake(195, 245, 100, 100))
        self.circularSlider = circularSlider
        circularSlider.handleType = EFHandleType.BigCircle
        circularSlider.handleColor = UIColor.grayColor()
        circularSlider.filledColor = UIColor.blackColor()
        circularSlider.unfilledColor = UIColor.whiteColor()
        circularSlider.lineWidth = 8
        circularSlider.minimumValue = 0
        circularSlider.maximumValue = 100
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCircularSlider()
        
        fullNameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        let user = PFUser.currentUser()
        let firstName = user!["firstName"] as! String
        let lastName = user!["lastName"] as! String
        fullNameLabel.text = "\(firstName) \(lastName)"
        
        //currentLocationSwitch.tintColor = UIColor.blackColor()
        currentLocationSwitch.onTintColor = UIColor.blackColor()
        logoutButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        staticSettingsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        staticCityLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        staticRadiusLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        currentLocationSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        locationLabel.font = UIFont.boldSystemFontOfSize(19.0)
        locationLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        staticMilesLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 10)
        radiusLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        staticCurrentLocationLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        
        peekButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        
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

        let currentUser = PFUser.currentUser()
        if (currentUser!["defaultCity"] != nil) {
            if currentUser!["defaultCity"] as! String != "" {
                self.circularSlider!.hidden = true
                staticRadiusLabel.hidden = true
                staticMilesLabel.hidden = true
                radiusLabel.hidden = true
                currentLocationSwitch.setOn(false, animated: true)
                let city = currentUser!["defaultCity"] as! String
                if city.hasSuffix("United States") {
                    //city.substringToIndex(Int(city.characters.count - 13))
                    let cityString = String(city.characters.dropLast(15))
                    locationLabel.text = cityString
                }
                else {
                    locationLabel.text = city
                }
            }
            else {
                //locationLabel.text = "Current Location"
                locationLabel.hidden = true
                staticCityLabel.hidden = true
                peekButton.hidden = true
                currentLocationSwitch.setOn(true, animated: true)
            }
        }
        

        //self.view.backgroundColor = UIColor.clearColor()
        //settingsView.layer.cornerRadius = settingsView.frame.width/32
        
        
        /*let imageToBlur = CIImage(image: UIImage(named: "newback")!)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        blurfilter!.setValue(15, forKey: "inputRadius")
        let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
        var blurredImage = UIImage(CIImage: resultImage)
        let cropped:CIImage=resultImage.imageByCroppingToRect(CGRectMake(0, 0,imageToBlur!.extent.size.width, imageToBlur!.extent.size.height))
        blurredImage = UIImage(CIImage: cropped)*/
        //backgroundView.image = UIImage(named: "newback")
        
        
        
        //backgroundView.alpha = 0.4
        //backgroundView.layer.cornerRadius = settingsView.frame.width/32
        backgroundView.clipsToBounds = true
        
        //settingsView.addSubview(backgroundView)
        settingsView.insertSubview(backgroundView, atIndex: 0)

        
        if currentUser!["radius"] != nil {
            circularSlider!.currentValue = currentUser!["radius"] as! Float
        }
        else {
            circularSlider!.currentValue = 0
        }
        circularSlider!.addTarget(self, action: #selector(self.newValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        //let labels: NSArray = [0.0, 1.0, 2.0, 3.0, 4.0]
        
        //circularSlider.setInnerMarkingLabels(labels as [AnyObject])
        circularSlider!.snapToLabels = true
        
        radiusLabel.text = String(Int(circularSlider!.currentValue))
        //radiusLabel.textColor = UIColor.whiteColor()
        settingsView.addSubview(circularSlider!)
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
    
    func cityPicked(city: String) {
        //locationLabel.textColor = UIColor.whiteColor()
        if city.hasSuffix("United States") {
            //city.substringToIndex(Int(city.characters.count - 13))
            let cityString = String(city.characters.dropLast(15))
            locationLabel.text = cityString
        }
        else {
            self.locationLabel.text = city
        }
    }
    
    func newValue(slider: EFCircularSlider) {
        radiusLabel.text = String(Int(slider.currentValue))
        self.newRadius = Int(slider.currentValue)
    }
    
    @IBAction func profilePicChangeTapped(sender: AnyObject) {
        self.alert()
    }
    @IBAction func currentCityTapped(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        currentUser!["defaultCity"] = ""
        currentUser!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
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
    @IBAction func currentLocationTapped(sender: AnyObject) {
        let currUser = PFUser.currentUser()
        locationLabel.text = "Current Location"
        currUser!["defaultCity"] = ""
        currUser!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "citySearchSegue" {
            let citiesVC = segue.destinationViewController as! CitiesViewController
            citiesVC.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
