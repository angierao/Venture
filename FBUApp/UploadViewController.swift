//
//  UploadViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/5/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AssetsLibrary
//import MBProgressHUD

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate {

    var newCard: Card?
    var newImage : UIImage?
    private lazy var client : ClarifaiClient = ClarifaiClient(appID: clarifaiClientID, appSecret: clarifaiClientSecret)

    @IBOutlet weak var buttonLibraryTapped: UIButton!
    @IBOutlet weak var buttonPromptCam: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var priceSegControl: UISegmentedControl!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var uploadButtonOutlet: UIButton!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var backgroundView: UIImageView!
    var venueId: String?
    var sentLocation : String?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var address: [NSString]?
    var city: String?
    var hour: NSDictionary?
    var video: Bool = false
    var videoData: NSData?
    var player: AVPlayer?
    var videoURLString: String?
    var videoFilePath: String?

    var tagResults = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageToBlur = CIImage(image: UIImage(named: "nyfull")!)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        blurfilter!.setValue(10, forKey: "inputRadius")
        let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
        var blurredImage = UIImage(CIImage: resultImage)
        let cropped:CIImage=resultImage.imageByCroppingToRect(CGRectMake(0, 0,imageToBlur!.extent.size.width, imageToBlur!.extent.size.height))
        blurredImage = UIImage(CIImage: cropped)
        //backgroundView.image = blurredImage
        
        
        
        //backgroundView.alpha = 0.4
        
        //settingsView.addSubview(backgroundView)
        //settingsView.insertSubview(backgroundView, atIndex: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        
        if let image = newImage {
            uploadImageView.image = image
        }
        uploadLabel.font = UIFont (name: "HelveticaNeue-Thin", size: 28)
        uploadButtonOutlet.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
        cancelButtonOutlet.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
        locationTextField.font = UIFont (name: "HelveticaNeue-Thin", size: 15)
        editButton.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
        buttonPromptCam.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 22)
        buttonLibraryTapped.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 22)
        editButton.layer.masksToBounds = false
        editButton.layer.cornerRadius = editButton.frame.height/2
        editButton.clipsToBounds = true
        self.navigationController?.navigationBarHidden = true
        
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    override func viewWillAppear(animated: Bool) {
        locationTextField.text = sentLocation
        self.navigationController?.navigationBarHidden = true
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        locationTextField.resignFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func locationTextFieldTouched(sender: AnyObject) {
        performSegueWithIdentifier("locationSearchSegue", sender: nil)
    }
    
    //func locationsPickedLocation(controller: LocationViewController, latitude: NSNumber, longitude: NSNumber)
    func locationsPickedLocation(latitude: NSNumber, longitude: NSNumber, sentLocation: String, address: [NSString], city: String, venueId: String)
    {
        //self.navigationController?.popToViewController(self, animated: true)
        self.sentLocation = sentLocation
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.venueId = venueId
        
        /*let locationCoordinate = CLLocationCoordinate2DMake(Double(latitutde), Double(longitude))
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = "Picture!"
        mapView.addAnnotation(annotation)*/
    }
    
    @IBAction func uploadFromCamButton(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    @IBAction func imageViewTapped(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        vc.mediaTypes = [(kUTTypeMovie as String), (kUTTypeImage as String)]
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        //let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let mediaType = info[UIImagePickerControllerMediaType]
        
        if mediaType!.isEqualToString(kUTTypeImage as String) {
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            
            // Do something with the images (based on your use case)
            uploadImageView.image = editedImage
            newImage = editedImage
            //Hide the button
            
        }
        
        else if mediaType!.isEqualToString(kUTTypeMovie as String) {
            /*
            
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            print(videoURL)
            let player = AVPlayer(URL: videoURL)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.uploadImageView.frame
            self.view.layer.addSublayer(playerLayer)
            self.player = player
            
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(self.playerItemDidReachEnd(_:)),
                                                             name: AVPlayerItemDidPlayToEndTimeNotification,
                                                             object: player.currentItem)
            player.play()*/

            
            video = true
            print(info)
            
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            //let localURL = NSURL(fileURLWithPath: "wolf.mov")
            let movieData = NSData(contentsOfURL: videoURL)
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let filePath = documentsPath.stringByAppendingString("/wolf.mov")
            do {
                try movieData?.writeToFile(filePath, options: .DataWritingAtomic)
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
            
            self.videoFilePath = filePath
            
            let videoURLString = videoURL.absoluteString
            self.videoURLString = videoURLString
            print(self.videoURLString)
            //let videoURL = NSURL(string: self.videoURLString!)
            self.videoData = NSData(contentsOfURL: videoURL)
            //let videoFile = PFFile(data: videoData!)
            
            let avAsset = AVURLAsset.init(URL: videoURL, options: nil)
            
            if avAsset.tracksWithMediaType(AVMediaTypeVideo).count > 0 {
                let imageGenerator = AVAssetImageGenerator(asset: avAsset)
                imageGenerator.appliesPreferredTrackTransform = true
                //let durationSeconds = CMTimeGetSeconds(avAsset.duration)
                //let midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600)
                //let actualTime = CMTime()
                do {
                    let imageRef = try imageGenerator.copyCGImageAtTime(kCMTimeZero, actualTime: nil)
                    //let actualTimeString = CMTimeCopyDescription(nil, actualTime)
                    //let requestedTimeString = CMTimeCopyDescription(nil, midpoint)
                    
                    let image = UIImage(CGImage: imageRef)
                    newImage = image
                    uploadImageView.hidden = true
                    
                    
                    let player = AVPlayer(URL: videoURL)
                    let playerLayer = AVPlayerLayer(player: player)
                    playerLayer.frame = self.uploadImageView.frame
                    self.view.layer.addSublayer(playerLayer)
                    self.player = player
                    
                    NSNotificationCenter.defaultCenter().addObserver(self,
                                                                     selector: #selector(self.playerItemDidReachEnd(_:)),
                                                                     name: AVPlayerItemDidPlayToEndTimeNotification,
                                                                     object: player.currentItem)
                    

                    player.play()
                    
                }
                catch {
                    print(error)
                }
            }
        }
        buttonLibraryTapped.hidden = true
        buttonPromptCam.hidden = true
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.player!.seekToTime(CMTimeMakeWithSeconds(0, 600))
        self.player!.play()
    }
    
    @IBAction func onUpload(sender: AnyObject) {
        if self.newImage != nil {
            // Display HUD right before the request is made
            //MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            let size = CGSizeMake(320, 320 * self.newImage!.size.height / self.newImage!.size.width)
            let resizedimage = resize(self.newImage!, newSize: size)
            
            //Catch if empty parameters
            if(self.latitude == nil || self.longitude == nil)
            {
                //Alert that location is necessary
                self.alert("EmptyParam")
                return
            }
            var successValue = false
            //var mediaData: NSData
            let locationText = locationTextField.text
            let priceValue = priceSegControl.selectedSegmentIndex
            
            if video {
                //mediaData = UIImagePNGRepresentation(newImage!)!
                successValue = Card.cardImage(resizedimage, withLocation: locationText, latitude: self.latitude!, longitude: self.longitude!, price: priceValue, address: self.address as? [String], city: self.city, venueId: self.venueId, url: self.videoURLString!, data: self.videoData!)
                
            }
            else {
                //mediaData = UIImagePNGRepresentation(newImage!)!
                //Tag the picture and upload
                //newCard?.setValue(resizedimage, forKey: "image")
                recognizeImage(resizedimage)
                
            }
            
            
            if(successValue)
            {
                // Hide HUD once the network request comes back (must be done on main UI thread)
                //0MBProgressHUD.hideHUDForView(self.view, animated: true)
                //print("THE CARD NOW STORES: \(newCard)")
                uploadImageView.hidden = true
                buttonLibraryTapped.hidden  = false
                buttonPromptCam.hidden = false
                locationTextField.text = ""
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else
            {
                print("Error posting")
            }
        }
        
    }
    
    
    func alert (type: String) {
        if(type == "Success")
        {
            let alertController = UIAlertController(title: "Success", message: "Posted picture", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                
            }
        }
        if(type == "EmptyParam")
        {
            let alertController = UIAlertController(title: "Error", message: "Location is required!", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
            }

        }
        else
        {
            let alertController = UIAlertController(title: "Error", message: "Try again later", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                
            }
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
                print("Results: \(results![0].tags) \(results![0].probabilities)")
                let alltags = results![0].tags
                self.tagResults = alltags
                print("Tags: \(self.tagResults)")
                var top8 = [String]()
                for i in 0 ..< 8 
                {
                    top8.append(alltags[i])
                }
                self.tagResults = top8
                
                print("Top8 tags: \(self.tagResults)")
                let locationText = self.locationTextField.text;
                let priceValue = self.priceSegControl.selectedSegmentIndex
                let successValue = Card.cardImage(self.newImage, withLocation: locationText, latitude: self.latitude!, longitude: self.longitude!, price: priceValue, address: self.address as? [String], city: self.city, venueId: self.venueId, tags: self.tagResults)
                
                
                if(successValue)
                {
                    // Hide HUD once the network request comes back (must be done on main UI thread)
                    //0MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    self.uploadImageView.hidden = true
                    self.buttonLibraryTapped.hidden  = false
                    self.buttonPromptCam.hidden = true
                    self.locationTextField.text = ""
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    self.alert("Success")
                }
                else
                {
                    self.alert("Error")
                    print("Error posting")
                }

                
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if  segue.identifier == "locationSearchSegue" {
            let vc = segue.destinationViewController as! LocationViewController
            vc.image = uploadImageView.image
            vc.delegate = self
        }
        if  segue.identifier == "editSegue" {
            if(newImage == nil)
            {
                self.alert()
            }
            else
            {
                let vc = segue.destinationViewController as! FiltersViewController
                vc.image = newImage
            }
        }
    }
    func alert () {
        let alertController = UIAlertController(title: "Error", message: "Choose a picture first.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Okay", style: .Default) { (action) in
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true) {}
    }
}
