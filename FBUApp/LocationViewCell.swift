//
//  LocationViewCell.swift
//  FBUApp
//
//  Created by Jedidiah Akano on 7/7/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit

class LocationViewCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var location: NSDictionary! {
        didSet {
            locationLabel.text = location["name"] as? String
            let city = location.valueForKeyPath("location.city") as? String
            let state = location.valueForKeyPath("location.state") as? String
            let address = (location.valueForKeyPath("location.address")) as? String
            var addressUnwrapped = ""
            if(address != nil)
            {
                addressUnwrapped += address!
            }
            if(city != nil)
            {
                if(address != nil)
                {
                    addressUnwrapped += ", "
                }
                addressUnwrapped += city!
            }
            if(state != nil)
            {
                if(city != nil || address != nil)
                {
                    addressUnwrapped += ", "
                }
                addressUnwrapped += state!
            }
            addressLabel.text = addressUnwrapped
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        locationLabel.font = UIFont (name: "HelveticaNeue-Thin", size: 17)
        locationLabel.font = UIFont.boldSystemFontOfSize(17)
        addressLabel.font = UIFont (name: "HelveticaNeue-Thin", size: 13)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
