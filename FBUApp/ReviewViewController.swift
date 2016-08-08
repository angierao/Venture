//
//  ReviewViewController.swift
//  FBUApp
//
//  Created by Angeline Rao on 7/11/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse

class ReviewViewController: UIViewController {

    var card: PFObject?
    
    @IBOutlet weak var profPicView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var reviewView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReviewViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
        //let user = PFUser.currentUser()
        //print(user!.username)
        //usernameLabel.text = user!.username
        //profPicView.layer.cornerRadius = profPicView.frame.height/2
        cancelButton.layer.masksToBounds = false
        cancelButton.layer.cornerRadius = cancelButton.frame.height/2
        cancelButton.clipsToBounds = true
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSubmit(sender: AnyObject) {
        let review = Review.newReview(reviewView.text)
        review.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print(review["text"])
                print("not error")
                print(self.card)
                if (self.card!["reviews"] as? [PFObject]) != nil {
                    var reviews = self.card!["reviews"] as! [PFObject]
                    reviews.append(review)
                    self.card!["reviews"] = reviews
                }
                else {
                    self.card?.setObject([review], forKey: "reviews")
                }
                self.card?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                    if success {
                        print("review added")
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {
                        print(error)
                    }
                })
            }
            else {
                print(error)
            }
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
