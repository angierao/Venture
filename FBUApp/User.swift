//
//  User.swift
//  FBUApp
//
//  Created by Jedidiah Akano on 7/6/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
// User model

import UIKit
import Parse

class User: PFUser {
    var firstName: String?
    //var lastName: String?
    //var userName: String?
    var dictionary: NSDictionary!
    var age: Int = 0
    var saved: [PFObject]?
    var radius: Float?

    
    init(dictionary: NSDictionary) {
        super.init()
        self.dictionary = dictionary
        firstName = dictionary["firstName"] as? String
        //lastName = dictionary["lastName"] as? String
        //userName = dictionary["username"] as? String
        age = (dictionary["age"] as? Int) ?? 0
        saved = []
        radius = (dictionary["radius"] as? Float) ?? 0
    }
    
    var userName: NSString {
        get {
            return (dictionary["username"] as? String)!
        }
    }
    
    var lastName: NSString {
        get {
            return (dictionary["lastName"] as? String)!
        }
    }
    var defaultCity: NSString {
        get {
            return(dictionary["defaultCity"] as? String)! 
        }
    }
    
    var currLoc: NSString {
        get {
            return(dictionary["currLoc"] as? String)!
        }
    }
    


}
