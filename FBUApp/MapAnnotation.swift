//
//  MapAnnotation.swift
//  FBUApp
//
//  Created by Jedidiah Akano on 7/26/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import MapKit
import Parse

class MapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "Details"
    }
    
    var card: PFObject?


}
