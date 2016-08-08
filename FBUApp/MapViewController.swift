//
//  MapViewController.swift
//  FBUApp
//
//  Created by Angeline Rao on 7/11/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import MapKit
import Parse

extension MapViewController: LocationsViewControllerDelegate {
    
    func locationsPickedLocation(latitude: NSNumber, longitude: NSNumber, sentLocation: String, address: [NSString], city: String, venueId: String) {
        self.navigationController?.popToViewController(self, animated: true)
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude as CLLocationDegrees, longitude: longitude as CLLocationDegrees)
        let annotation = MapAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.photo = image
        mapView.addAnnotation(annotation)
    }
}

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var saved: [PFObject]?
    var thumbnails: [NSValue : PFFile]?
    var annotationCard: PFObject?
    var venueId: [NSValue: String]?
    let savedKey = "savedCards"

    var lats: [Double] = []
    var lngs: [Double] = []
    var image: UIImage?
    var currLat: Double?
    var currLng: Double?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        thumbnails = [NSValue: PFFile]()
        
       

        
        // Do any additional setup after loading the view.
        
        let user = PFUser.currentUser()
        saved = user![savedKey] as? [PFObject]
        
        mapView.delegate = self
        setThumbnails()
        
        
    }
    
    
    
    func setThumbnails() {
        var count = 0
        if(saved != nil)
        {
            for save in saved! {
                count += 1
                save.fetchInBackgroundWithBlock({ (save: PFObject?, error: NSError?) in
                    if save != nil {
                        
                        let lat = save!["latitude"] as! Double
                        let lng = save!["longitude"] as! Double
                        self.lats.append(lat)
                        self.lngs.append(lng)
                        
                        let annotation = MapAnnotation()
                        let location = CLLocationCoordinate2DMake(lat, lng)
                        annotation.coordinate = location
                        annotation.card = save
                        self.annotationCard = save
                        let imageFile = save!["media"] as! PFFile
                        
                        self.thumbnails![NSValue(nonretainedObject: annotation)] = imageFile
                        
                        
                        self.mapView.addAnnotation(annotation)
                        
                        if count == self.saved?.count {
                            
                            let minLat = self.lats.minElement()
                            let maxLat = self.lats.maxElement()
                            let minLng = self.lngs.minElement()
                            let maxLng = self.lngs.maxElement()
                            
                            let diffLat = 3*max(maxLat! - self.currLat!, self.currLat! - minLat!)
                            let diffLng = 3*max(maxLng! - self.currLng!, self.currLng! - minLng!)
                            
                            let currRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.currLat!, self.currLng!), MKCoordinateSpanMake(diffLat, diffLng))
                            self.mapView.setRegion(currRegion, animated: false)
                        }
                        
                    }
                })
            }
            
        }
        else
        {
            print("Saved is nil")
        }
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
               performSegueWithIdentifier("mapToDetailSegue", sender: view)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        
        
         if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            //let label = UILabel(frame: CGRectMake(0, 0, 75, 20))
            //label.text = "Details"
            //annotationView!.leftCalloutAccessoryView = label
            annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            
            if let detailButton = annotationView?.rightCalloutAccessoryView as? UIButton {
            //detailButton
            }
         
        }
        
         let resizeRenderImageView = UIImageView(frame: CGRectMake(0, 0, 45, 45))
        
         //resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
 
 
         //let imageFile = card!["media"] as! PFFile
 
        resizeRenderImageView.layer.borderColor = UIColor.whiteColor().CGColor
        resizeRenderImageView.layer.borderWidth = 0.0
        resizeRenderImageView.layer.cornerRadius = resizeRenderImageView.frame.height/2
        resizeRenderImageView.clipsToBounds = true
        
        let imageFile = thumbnails![NSValue(nonretainedObject: annotation)]
        
        imageFile?.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
            if data != nil {
                self.image = UIImage(data: data!)
                resizeRenderImageView.image = self.image
                UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
                resizeRenderImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                annotationView!.image = thumbnail
            }
        })
        
        
        
        
        
        

 /*
         imageFile.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) in
 
         if data != nil {
         print("image loaded")
         let image = UIImage(data: data!)
         resizeRenderImageView.image = image
 
         UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
         resizeRenderImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
         let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         annotationView.image = thumbnail
 
         }
         else {
         print(error)
         }
            
        }*/
    return annotationView
    //resizeRenderImageView.file = card!["media"] as? PFFile
    //resizeRenderImageView.contentMode = UIViewContentMode.ScaleAspectFill
    
    //resizeRenderImageView.loadInBackground()
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "mapToDetailSegue" {
            let detailVC = segue.destinationViewController as! ManagePageViewController
            /*let indexPath = collectionView.indexPathForCell(sender as! UICollectionViewCell)
            let card = saved![indexPath!.row]
            detailVC.card = card
            let cardImageFile = card["media"]
            cardImageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
                if(error == nil)
                {
                    let dataImage = UIImage(data: data!)
                    detailVC.particularImage = dataImage
                }
            }) */
            let newCard = (sender as! MKAnnotationView).annotation! as! MapAnnotation
            detailVC.card  = newCard.card
            detailVC.currLat = self.currLat
            detailVC.currLong = self.currLng
        }
    }
}

 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


