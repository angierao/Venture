//
//  ReviewTableCell.swift
//  FBUApp
//
//  Created by Angeline Rao on 7/12/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit

class ReviewTableCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var profPicView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
