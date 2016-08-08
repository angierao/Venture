//
//  WelcomeViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/5/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import VideoSplashKit

class WelcomeViewController: VideoSplashViewController {

    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var discoverCaptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.hidden = true
        playInBackground()
        let attributedLoginLabel = NSMutableAttributedString(string: "Log in")
        attributedLoginLabel.addAttribute(NSKernAttributeName, value: CGFloat(5), range: NSRange(location: 0, length: 6))
        loginButton.titleLabel?.attributedText = attributedLoginLabel
        
        let attributedsignUpLabel = NSMutableAttributedString(string: "Sign up")
        attributedsignUpLabel.addAttribute(NSKernAttributeName, value: CGFloat(5), range: NSRange(location: 0, length: 7))
        signUpButton.titleLabel?.attributedText = attributedsignUpLabel
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func playInBackground() {
        backgroundView.hidden = true
        
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("traffic2", ofType: "mp4")!)
        self.videoFrame = view.frame
        self.fillMode = .ResizeAspectFill
        self.alwaysRepeat = true
        self.sound = false
        self.startTime = 0.0
        self.duration = 20.0
        self.alpha = 0.7
        self.backgroundColor = UIColor.blackColor()
        self.contentURL = url
        self.restartForeground = true
        let attributedString = NSMutableAttributedString(string: "Venture")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(10), range: NSRange(location: 0, length: 7))
        //let font = UIFont(name: "HelveticaNeue", size: 40)
        //let attributes = [NSFontAttributeName: font]
        //attributedString.addAttributes(attributes, range: NSRange(location:0, length:7))
        titleLabel.attributedText = attributedString
        discoverCaptionLabel.font = UIFont (name: "SavoyeLetPlain", size: 33)
        
        //titleLabel.font = UIFont (name: "HelveticaNeue", size: 40)

        
    }


}
