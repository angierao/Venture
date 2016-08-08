//
//  FourSquareLocation.swift
//  FBUApp
//
//  Created by Jedidiah Akano on 7/6/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse

class FourSquareClient: NSObject {
    var results: NSArray = []
    var venueInfo: NSArray = []
    var location: String?
    var venuId: String?
    let CLIENT_ID = "VM3U2MOM4P4IOVBQMZW5NSQH1MJEANGW51YA4SVMW4JLAEBH"
    let CLIENT_SECRET = "5FHY2RUJVEW2YRHJ3J53XN5J0U2HUY5KNQMFSCHJVMQPMDUC"
    
    
    override init() {
        super.init()
        location = ""
        
    }
    
    func fetchLocations(query: String) {
        let currentUser = PFUser.currentUser()

        let near = "San Francisco, CA, United States"
        if(currentUser!["defaultCity"] != nil && currentUser!["defaultCity"] as! String != "")
        {
            print("\(currentUser)")
            print(query)
            print("went into: \(currentUser!["defaultCity"])")
            //near = currentUser!["defaultCity"] as! String
        }
        let baseUrlString = "https://api.foursquare.com/v2/venues/search?"
        let queryString = "&client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&v=20141020&near=\(near)&query=\(query)"
        
        let url = NSURL(string: baseUrlString + queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        print(url)
        let request = NSURLRequest(URL: url)
        print(url)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                    //NSLog("response: \(responseDictionary)")
                    self.results = responseDictionary.valueForKeyPath("response.venues") as! NSArray
                    dispatch_async(dispatch_get_main_queue()) {
                        NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
                    }
                }
            }
        });
        task.resume()
    }

   
    func fetchVenueInfo(venueID: String, completion: (Venue -> Void)!) {
        let baseUrlString = "https://api.foursquare.com/v2/venues/\(venueID)?"
        let queryString = "&client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&v=20141020"
        
        
        let url = NSURL(string: baseUrlString + queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        //print(url)
        let request = NSURLRequest(URL: url)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                    //NSLog("response: \(responseDictionary)")
                    //print("Its good: \(responseDictionary)")
                    let venueInfo = responseDictionary.valueForKeyPath("response") as! NSDictionary
                    let venue = Venue(dictionary: venueInfo)
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0), {
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(venue)
                        })
                    })
                }
                
                
            }
        });
        
        task.resume()
        
        
    }

}
