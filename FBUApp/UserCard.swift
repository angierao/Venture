//
//  UserCard.swift
//  FBUApp
//
//  Created by Angeline Rao on 7/19/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse

class UserCard: NSObject {
    class func newUserCard(user: PFUser, card: PFObject, date: NSDate) -> PFObject {
        let userCard = PFObject(className: "UserCard")
        /*
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day, .Hour , .Minute, .Second], fromDate:date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let min = components.minute
        let sec = components.second
        
        let currentDate = NSDateComponents()
        currentDate.year = year
        currentDate.month = month
        currentDate.day = day
        currentDate.hour = hour
        currentDate.minute = min
        currentDate.second = sec
        
        let today = NSCalendar.currentCalendar().dateFromComponents(currentDate)!
        
        let dateFormatter = NSDateFormatter()
        //let date = NSDate()
        dateFormatter.dateFormat = "MMM d, H:mm a"
        let dateString = dateFormatter.stringFromDate(today)*/
        
        let username = user.username
        let objectId = card.objectId
        
        userCard["userCardId"] = username! + "$" + objectId!
        userCard["card"] = card
        userCard["status"] = "down"
        userCard["date"] = date
        
        userCard.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if error != nil {
                print(error)
            }
        }
        
        return userCard
    }

}
