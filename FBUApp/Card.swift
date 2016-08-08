//
//  Card.swift
//  FBUApp
//
//  Created by Jedidiah Akano on 7/6/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse

class Card: NSObject {
    
    var distanceData = NSDictionary()
    var distance = String?.self
    

    class func cardImage(image: UIImage?, withLocation location: String?, latitude: NSNumber, longitude: NSNumber, price: Int?, address: [String]?, city: String?, venueId: String?, tags: [String]?) -> Bool {
        // Create Parse object PFObject
        var successOverall = true
        let card = PFObject(className: "Card")
        
        // Add relevant fields to the object
        card["media"] = getPFFileFromImage(image) // PFFile column type
        card["author"] = PFUser.currentUser() // Pointer column type that points to PFUser
        card["location"] = location!
        card["likesCount"] = 0
        card["dislikesCount"] = 0
        card["commentsCount"] = 0
        card["price"] = price!
        //card["tipCount"] = tips! //Avalaible in venue["stats"]
        //card["address"] = address! //Available in venue["location"]
        //card["distance"] = distance! //Available in venue["location"]
        card["addressArray"] = address!
        card["latitude"] = latitude
        card["longitude"] = longitude
        card["reviews"] = []
        card["city"] = city
        card["venueId"] = venueId
        card["tags"] = tags
        // Save object (following function will save the object in Parse asynchronously)
        card.saveInBackgroundWithBlock{(success, error) -> Void in
            if(error == nil)
            {
                //Success
                print("Success")
                
            }
            else
            {
                print("Error")
                successOverall = false
            }
        }
        
        return successOverall
        
    }
    
    class func cardImage(image: UIImage?, withLocation location: String?, latitude: NSNumber, longitude: NSNumber, price: Int?, address: [String]?, city: String?, venueId: String?, url: String, data: NSData) -> Bool {
        // Create Parse object PFObject
        var successOverall = true
        let card = PFObject(className: "Card")
        
        // Add relevant fields to the object
        card["media"] = getPFFileFromImage(image) // PFFile column type
        //card["image"] = image
        card["author"] = PFUser.currentUser() // Pointer column type that points to PFUser
        card["location"] = location!
        card["likesCount"] = 0
        card["dislikesCount"] = 0
        card["commentsCount"] = 0
        card["price"] = price!
        //card["tipCount"] = tips! //Avalaible in venue["stats"]
        //card["address"] = address! //Available in venue["location"]
        //card["distance"] = distance! //Available in venue["location"]
        card["addressArray"] = address!
        card["latitude"] = latitude
        card["longitude"] = longitude
        card["reviews"] = []
        card["city"] = city
        card["venueId"] = venueId
        if url != "" {
            card["videoUrl"] = url
            print(url)
        }
        card["videoData"] = getPFFileFromData(data)
        // Save object (following function will save the object in Parse asynchronously)
        card.saveInBackgroundWithBlock{(success, error) -> Void in
            if(error == nil)
            {
                //Success
                print("Success")
                
            }
            else
            {
                print("Error")
                successOverall = false
            }
        }
        
        return successOverall
        
    }

    
    /**
     Method to convert UIImage to PFFile
     
     - parameter image: Image that the user wants to upload to parse
     
     - returns: PFFile for the the data in the image
     */
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
    
    class func getPFFileFromData(data: NSData) -> PFFile {
        return PFFile(data: data)!
    }
    /*
    func getDistance(lat1: Double, long1: Double, lat2: Double, long2 : Double) -> String?.Type
    {
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
                print("Data isnt nil")
                let data = dataOrNil
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as? NSDictionary {
                    self.distanceData = responseDictionary
                    print(self.distanceData)
                    let rowsDict = self.distanceData.valueForKey("rows") as! [NSDictionary]
                    let rowsDictFirstRow = rowsDict[0]
                    let elementsDict = rowsDictFirstRow.valueForKey("elements") as! [NSDictionary]
                    let elementsFirstRow = elementsDict[0]
                    let distanceDict = elementsFirstRow.valueForKey("distance") as! NSDictionary
                    let distance = distanceDict.valueForKey("text")
                                                        }
            }
        })
        task.resume()
        return distance!
    }*/
    
    
}


