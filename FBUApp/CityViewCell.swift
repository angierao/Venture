//
//  CityViewCell.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/8/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit

class CityViewCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cityLabel.font = UIFont (name: "BodoniSvtyTwoSCITCTT-Book", size: 16)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
