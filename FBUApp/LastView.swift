//
//  LastView.swift
//  FBUApp
//
//  Created by Angeline Rao on 7/7/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit


class LastView: UIView {

    let imageMarginSpace: CGFloat = 3.0
    //var pictureView: PFImageView!
    var pictureView: UIImageView!
    var likesLabel: UILabel!
    var distanceLabel: UILabel!
    var originalCenter: CGPoint!
    var animator: UIDynamicAnimator!
    
    //init(frame: CGRect, center: CGPoint, image: UIImage) {
    init(frame: CGRect, center: CGPoint, image: UIImage) {
        super.init(frame: frame)
        
        //self.pictureView = PFImageView()
        //self.pictureView.file = file
        //self.pictureView.loadInBackground()
        /*
         if card == nil {
         self.pictureView.image = UIImage()
         self.likesLabel.text = ""
         self.distanceLabel.text = ""
         }
         else {*/
        self.pictureView = UIImageView()
        self.pictureView.image = image
        
        self.likesLabel = UILabel()
        likesLabel.text = ""
        self.distanceLabel = UILabel()
        distanceLabel.text = ""
        
        //var image = UIImage()
        
        self.center = center
        self.originalCenter = center
        //self.animator = UIDynamicAnimator(referenceView: self)
        
        self.pictureView.frame = CGRectIntegral(CGRectMake(
            0.0 + self.imageMarginSpace,
            0.0 + self.imageMarginSpace,
            self.frame.width - (2 * self.imageMarginSpace),
            self.frame.height - (2 * self.imageMarginSpace)
            ))
        
        self.addSubview(self.pictureView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
