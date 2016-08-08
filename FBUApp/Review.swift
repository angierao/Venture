//
//  Review.swift
//  FBUApp
//
//  Created by Angeline Rao on 7/11/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse

class Review: NSObject {
    //class func newReview(content: String, withCompletion completion: PFBooleanResultBlock?) -> PFObject {
    class func newReview(content: String) -> PFObject {
        let review = PFObject(className: "Review")
        
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
        let dateString = dateFormatter.stringFromDate(today)
        
        review["creationString"] = dateString
        review["text"] = content
        review["author"] = PFUser.currentUser()
        
        
        
        return review
    }
}
