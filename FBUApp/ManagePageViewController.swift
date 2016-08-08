//
//  ManagePageViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 8/1/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MapKit
import FBSDKShareKit
import ParseFacebookUtilsV4
import AVKit
import AVFoundation

//MARK: implementation of UIPageViewControllerDataSource
extension ManagePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}

class ManagePageViewController: UIPageViewController {
    
    var url: String?
    var venue : Venue?
    var hours: NSDictionary?
    var photos: NSDictionary?
    var card: PFObject?
    var distance: String?
    var price: Int?
    var name: String?
    var tips: Double?
    var createdAt: NSDate?
    var address: NSArray?
    var distanceData: NSDictionary?
    var currLat : Double?
    var currLong: Double?
    let user = PFUser.currentUser()
    var cardLat: Double?
    var cardLong: Double?
    var venueId: String?
    var reviews: [PFObject]?
    var player: AVPlayer?
    var playButton: UIButton?

    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController(1),
                self.newColoredViewController(2),
                self.newColoredViewController(3),
                self.newColoredViewController(4)
        ]
    }()
    
    private func newColoredViewController(num: Int) -> UIViewController {
        
        if(num == 1)
        {
            let vc = UIStoryboard(name: "Main", bundle: nil) .
                instantiateViewControllerWithIdentifier("1VC") as! ONEViewController
            vc.card = card

            vc.currLat = self.currLat
            vc.currLong = self.currLong
            vc.distance = self.distance
            return vc
        }
        if(num == 2)
        {
            let vc = UIStoryboard(name: "Main", bundle: nil) .
                instantiateViewControllerWithIdentifier("2VC") as! TWOViewController
            vc.card = card
            vc.currLat = self.currLat
            vc.currLong = self.currLong
            vc.distance = self.distance
            return vc
        }
        if(num == 3)
        {
            let vc = UIStoryboard(name: "Main", bundle: nil) .
                instantiateViewControllerWithIdentifier("3VC") as! THREEViewController
            vc.card = card
            vc.currLat = self.currLat
            vc.currLong = self.currLong
            vc.distance = self.distance
            return vc
        }
        if(num == 4)
        {
            let vc = UIStoryboard(name: "Main", bundle: nil) .
                instantiateViewControllerWithIdentifier("4VC") as! FOURViewController
            vc.card = card
            vc.currLat = self.currLat
            vc.currLong = self.currLong
            vc.distance = self.distance
            return vc
        }
        else
        {
            return UIStoryboard(name: "Main", bundle: nil) .
                instantiateViewControllerWithIdentifier("1VC") as! ONEViewController

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .Forward,
                               animated: true,
                               completion: nil)
        }
        
    }
    
}