//
//  VenuePhotosViewController.swift
//  FBUApp
//
//  Created by Jedidiah Akano on 7/20/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit

class VenuePhotosViewController: UIViewController {
    var url: String?

    @IBOutlet weak var enlargedPhotoView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImage() {
        if self.url != nil {
            print("The URL is: \(self.url)")
            let actualURl = NSURL(string: self.url!)
            self.enlargedPhotoView.setImageWithURL(actualURl!)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
