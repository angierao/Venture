//
//  Venue.swift
//  FBUApp
//
//  Created by Jedidiah Akano on 7/13/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit

class Venue: NSObject {
    var hours: NSDictionary
    var photos: NSDictionary
    var url: String
    var name: String
    init(dictionary: NSDictionary) {
        //print("dictionary: \(dictionary)")
        let venueDictionary = dictionary.valueForKey("venue")
        //print("This exist: \(venueDictionary!.valueForKey("popular")))")
        if (venueDictionary!["hours"] as? NSDictionary) != nil {
             //print("This exist: \(venueDictionary!["hours"])))")
            
            self.hours = venueDictionary!["hours"] as! NSDictionary
        } else {
            self.hours = ["time" : "not available"]
        }
        
        if (venueDictionary!["photos"] as? NSDictionary) != nil {
            //print("This exist: \(venueDictionary!["photos"])))")
            
            self.photos = venueDictionary!["photos"] as! NSDictionary
        } else {
            self.photos = ["photos" : "not available"]
        }
        
        if (venueDictionary!["url"] as? String) != nil {
            //print("This exist: \(venueDictionary!["url"])))")
            
            self.url = venueDictionary!["url"] as! String
        } else {
            self.url = "not available"
        }
        if (venueDictionary!["name"] as? String) != nil {
            self.name = venueDictionary!["name"] as! String
        } else {
            self.name = "Anonymous location"
        }


    }
    
    func getStringFromJSON(dictionary: NSDictionary, key: String) -> String {
        //print("dictionary: \(dictionary)")        
        if let info = dictionary[key] as? String {
            return info
        }
        return ""
    }

}
