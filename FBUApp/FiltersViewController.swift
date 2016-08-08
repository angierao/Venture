//
//  FiltersViewController.swift
//  FBUApp
//
//  Created by Angeline Rao on 7/18/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController, UINavigationControllerDelegate, LocationsViewControllerDelegate {

    @IBAction func locationTextFieldTapped(sender: AnyObject) {
        performSegueWithIdentifier("locationSearchSegueFromFilters", sender: nil)
    }
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var priceSegControl: UISegmentedControl!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var picImageView: UIImageView!
    //All the buttons for filters
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var buton3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    
    private lazy var client : ClarifaiClient = ClarifaiClient(appID: clarifaiClientID, appSecret: clarifaiClientSecret)

    
    typealias Filter = CIImage -> CIImage
    var image:UIImage?
    var venueId: String?
    var sentLocation : String?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var address: [NSString]?
    var city: String?
    var editedImage:UIImage?
    var tags : [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadButton.layer.masksToBounds = false
        uploadButton.layer.cornerRadius = uploadButton.frame.height/2
        uploadButton.clipsToBounds = true
        uploadButton.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 13)
        locationTextField.font = UIFont (name: "HelveticaNeue-Thin", size: 16)
        button1.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 16)
        button2.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 16)
        buton3.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 16)
        button4.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 16)
        button5.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 16)
        button6.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 16)
        button7.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 16)
        button8.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 16)
        self.logAllFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func logAllFilters() {
        let properties = CIFilter.filterNamesInCategory(kCICategoryBuiltIn)
        print(properties)
        
        for filterName: AnyObject in properties {
            let fltr = CIFilter(name:filterName as! String)
            print(fltr!.attributes)
        }
    }
    func locationsPickedLocation(latitude: NSNumber, longitude: NSNumber, sentLocation: String, address: [NSString], city: String, venueId: String)
    {
        self.sentLocation = sentLocation
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.venueId = venueId
        
        locationTextField.text = sentLocation
    }

    @IBAction func uploadTapped(sender: AnyObject) {
        // Display HUD right before the request is made
        //MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        //Catch if empty parameters
        if(self.latitude == nil || self.longitude == nil)
        {
            //Alert that location is necessary
            self.alert("EmptyParam")
            return
        }
        
        
    }
    @IBAction func filter1Tapped(sender: AnyObject) {
        let filter = CIFilter(name: "CISepiaTone")
        let imageSentCI = CIImage(image: image!)
        filter!.setValue(imageSentCI, forKey: kCIInputImageKey)
        filter!.setValue(0, forKey: kCIInputIntensityKey)
        let context = CIContext(options:nil)
        
        let cgimg = context.createCGImage(filter!.outputImage!, fromRect: filter!.outputImage!.extent)
        
        let newImage = UIImage(CGImage: cgimg)
        self.picImageView.image = newImage
        self.editedImage = newImage

    }
    @IBAction func filter2Tapped(sender: AnyObject) {
        let filter = CIFilter(name: "CISepiaTone")
        let imageSentCI = CIImage(image: image!)
        filter!.setValue(imageSentCI, forKey: kCIInputImageKey)
        filter!.setValue(0.9, forKey: kCIInputIntensityKey)
        let context = CIContext(options:nil)
        
        let cgimg = context.createCGImage(filter!.outputImage!, fromRect: filter!.outputImage!.extent)
        
        let newImage = UIImage(CGImage: cgimg)
        self.picImageView.image = newImage
        self.editedImage = newImage

    }
    @IBAction func filter3Tapped(sender: AnyObject) {
        let filter = CIFilter(name: "CIColorMonochrome")
        let imageSentCI = CIImage(image: image!)
        filter!.setValue(imageSentCI, forKey: kCIInputImageKey)
        filter!.setValue(1.0, forKey: kCIInputIntensityKey)
        let colorWhite = CIColor(color: UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1))
        filter!.setValue(colorWhite, forKey: kCIInputColorKey)
        
        
        let context = CIContext(options:nil)
        
        let cgimg = context.createCGImage(filter!.outputImage!, fromRect: filter!.outputImage!.extent)
        
        let newImage = UIImage(CGImage: cgimg)
        self.picImageView.image = newImage
        self.editedImage = newImage

    }
    @IBAction func filter4Tapped(sender: AnyObject) {
        let filter = CIFilter(name: "CIVibrance")
        let imageSentCI = CIImage(image: image!)
        filter!.setValue(imageSentCI, forKey: kCIInputImageKey)
        filter!.setDefaults()
        filter!.setValue(1, forKey: "inputAmount")
        
        let context = CIContext(options:nil)
        
        let cgimg = context.createCGImage(filter!.outputImage!, fromRect: filter!.outputImage!.extent)
        
        let newImage = UIImage(CGImage: cgimg)
        self.picImageView.image = newImage
        self.editedImage = newImage


    }
    @IBAction func filter5Tapped(sender: AnyObject) {
        let filter = CIFilter(name: "CIGloom")
        let imageSentCI = CIImage(image: image!)
        filter!.setValue(imageSentCI, forKey: kCIInputImageKey)
        filter!.setValue(5, forKey: kCIInputRadiusKey)
        filter!.setValue(1, forKey: kCIInputIntensityKey)
        let context = CIContext(options:nil)
        
        let cgimg = context.createCGImage(filter!.outputImage!, fromRect: filter!.outputImage!.extent)
        
        let newImage = UIImage(CGImage: cgimg)
        self.picImageView.image = newImage
        self.editedImage = newImage


    }
    @IBAction func filter6Tapped(sender: AnyObject) {
        let filter = CIFilter(name: "CIVignetteEffect")
        let imageSentCI = CIImage(image: image!)
        filter!.setValue(imageSentCI, forKey: kCIInputImageKey)
        filter!.setDefaults()
        filter!.setValue(0.3, forKey: kCIInputIntensityKey)

        let context = CIContext(options:nil)
        
        let cgimg = context.createCGImage(filter!.outputImage!, fromRect: filter!.outputImage!.extent)
        
        let newImage = UIImage(CGImage: cgimg)
        self.picImageView.image = newImage
    }
    @IBAction func filter7Tapped(sender: AnyObject) {
        let filter = CIFilter(name: "CIBloom")
        let imageSentCI = CIImage(image: image!)
        filter!.setValue(imageSentCI, forKey: kCIInputImageKey)
        filter!.setDefaults()
        filter?.setValue(1, forKey: kCIInputIntensityKey)
        filter?.setValue(5, forKey: kCIInputRadiusKey)
        let context = CIContext(options:nil)
        
        let cgimg = context.createCGImage(filter!.outputImage!, fromRect: filter!.outputImage!.extent)
        
        let newImage = UIImage(CGImage: cgimg)
        self.picImageView.image = newImage
        self.editedImage = newImage

    }
    @IBAction func filter8Tapped(sender: AnyObject) {
        let filter = CIFilter(name: "CIUnsharpMask")
        let imageSentCI = CIImage(image: image!)
        filter!.setValue(imageSentCI, forKey: kCIInputImageKey)
        filter!.setValue(0.5, forKey: kCIInputIntensityKey)
        
        let context = CIContext(options:nil)
        
        let cgimg = context.createCGImage(filter!.outputImage!, fromRect: filter!.outputImage!.extent)
        
        let newImage = UIImage(CGImage: cgimg)
        self.picImageView.image = newImage

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
                self.tags = alltags
                print("Tags: \(self.tags)")
                var top8 = [String]()
                for i in 0 ..< 8
                {
                    top8.append(alltags[i])
                }
                self.tags = top8
                let locationText = self.locationTextField.text;
                let priceValue = self.priceSegControl.selectedSegmentIndex
                let successValue = Card.cardImage(self.editedImage, withLocation: locationText, latitude: self.latitude!, longitude: self.longitude!, price: priceValue, address: self.address as? [String], city: self.city, venueId: self.venueId, tags: self.tags)
                if(successValue)
                {
                    print("Success")
                    self.locationTextField.text = ""
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                }
                else
                {
                    self.alert("Error")
                    print("Error posting")
                }
                print("Top8 tags: \(self.tags)")
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "locationSearchSegueFromFilters")
        {
            let vc = segue.destinationViewController as! LocationViewController
            vc.delegate = self
        }
    }
    func alert (type: String) {
        if(type == "EmptyParam")
        {
            let alertController = UIAlertController(title: "Error", message: "Add a location to picture first.", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                
            }
        }

    }
    

}
