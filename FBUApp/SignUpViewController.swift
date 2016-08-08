//
//  SignUpViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/5/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, CitiesViewControllerDelegate {

    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        let attributedSignUpLabel = NSMutableAttributedString(string: "Sign up")
        attributedSignUpLabel.addAttribute(NSKernAttributeName, value: CGFloat(5), range: NSRange(location: 0, length: 7))
        signUpLabel.attributedText = attributedSignUpLabel
        
        signInButton.layer.masksToBounds = false
        signInButton.layer.cornerRadius = signInButton.frame.height/2
        signInButton.clipsToBounds = true
        firstNameTextField.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
        lastNameTextField.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
        usernameTextField.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
        passwordTextField.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
        ageTextField.font = UIFont (name: "HelveticaNeue-Thin", size: 20)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tap(gesture: UITapGestureRecognizer) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        
    }

    @IBAction func touchCityTextField(sender: AnyObject) {
        performSegueWithIdentifier("signUpSegueToCities", sender: nil)
    }
    @IBAction func onDismiss(sender: AnyObject) {
         dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func onSignUp(sender: AnyObject) {
        // initialize a user object
        let newUser = PFUser()
        
        // set user properties
        newUser.username = usernameTextField.text
        newUser.password = passwordTextField.text
        
        
        // call sign up function on the object
        newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                print(error)
                if error.code == 202 {
                    let alertController = UIAlertController(title: "Username is taken.", message: "Please enter a new username.", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                    }
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true, completion:nil)
                    
                }
            } else {
                let currUser = PFUser.currentUser()
                currUser!.setObject(self.firstNameTextField.text!, forKey: "firstName")
                currUser!.setObject(self.lastNameTextField.text!, forKey: "lastName")
                currUser!.setObject(self.ageTextField.text!, forKey: "defaultCity") //it says age but its actually the city now
                currUser!.setObject(50, forKey: "radius")
                currUser!.setObject(5, forKey: "notificationRadius")
                let empty: [PFObject] = []
                currUser!.setObject(empty, forKey: "savedCards")
                let firstNameCurrUser = currUser?["firstName"] as! String
                print(firstNameCurrUser)
                let saved = currUser?["savedCards"] as! [PFObject]
                print(saved.count)
                
                self.performSegueWithIdentifier("signUpSegue", sender: nil)
                // manually segue to logged in view
                
            }
        }
    }
    func cityPicked(city: String) {
        ageTextField.text = city
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "signUpSegueToCities" {
            let vc = segue.destinationViewController as! CitiesViewController
            vc.delegate = self
        }
    }


}
