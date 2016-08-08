//
//  ImageViewWithGradient.swift
//  FBUApp
//
//  Created by Angeline Rao on 7/28/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit

class ImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        let colors: [CGColorRef] = [
            UIColor.clearColor().CGColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).CGColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor,
            UIColor.clearColor().CGColor ]
        myGradientLayer.colors = colors
        myGradientLayer.opaque = false
        myGradientLayer.locations = [0.0,  0.3, 0.5, 0.7, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

