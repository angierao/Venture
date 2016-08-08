//
//  LoginViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/5/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var bridgeBackground: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var logInButtonNonFB: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    var pictureImage : UIImage?
    var userDict : NSDictionary?
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
        view.addSubview(loginButton)
        loginButton.frame = CGRectMake(70, 300, 244, 39)
        loginButton.delegate = self
        loginButton.alpha = 0.03
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            fetchProfile()
        }
        let attributedLoginLabel = NSMutableAttributedString(string: "Log in")
        attributedLoginLabel.addAttribute(NSKernAttributeName, value: CGFloat(5), range: NSRange(location: 0, length: 6))
        loginLabel.attributedText = attributedLoginLabel

        orLabel.font = UIFont (name: "HelveticaNeue", size: 30)
        logInButtonNonFB.layer.masksToBounds = false
        logInButtonNonFB.layer.cornerRadius = logInButtonNonFB.frame.height/2
        logInButtonNonFB.clipsToBounds = true
        usernameField.font = UIFont (name: "HelveticaNeue", size: 20)
        passwordField.font = UIFont (name: "HelveticaNeue", size: 20)
        
        
    }
    
    func fetchProfile() {

        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler { (connection, result, error) in
            if error != nil {
                print(error)
            }
            else {
                let dict = result as! NSDictionary
                print(dict)
                self.userDict = dict
                print(PFUser.currentUser())
                let pictureDict = result.valueForKey("picture") as! NSDictionary
                let dataPictureDict = pictureDict.valueForKey("data") as! NSDictionary
                let pictureURLString = dataPictureDict.valueForKey("url") as! String
                let pictureURL = NSURL(string: pictureURLString)
                let data = NSData(contentsOfURL:pictureURL!)
                if data != nil {
                    self.pictureImage = UIImage(data:data!)
                }
                let PFFileImage = self.getPFFileFromImage(self.pictureImage)
                let currentUser = PFUser.currentUser()
                print(currentUser)
                currentUser?["profileImage"] = PFFileImage
                let firstNameReturned = result.valueForKey("first_name")
                currentUser?["firstName"] = firstNameReturned
                currentUser?.setObject(firstNameReturned!, forKey: "firstName")
                let lastNameReturned = result.valueForKey("last_name")
                currentUser?["lastName"] = lastNameReturned
                currentUser?.setObject(lastNameReturned!, forKey: "lastName")
                print(" HELLO HERE \(firstNameReturned) \(lastNameReturned)")
                //print(currentUser!["fbId"])
                
                
                let fbid = result.valueForKey("id")
                print(fbid)
                currentUser?.setObject(fbid!, forKey: "fbId")

                currentUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                    if(success)
                    {
                        print("Successfully saving user's info")
                    }
                    else
                    {
                        print("Error saving user's info\(error)")
                    }
                })
            }
        }
    }
    
    func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }

    @IBAction func onDismiss(sender: AnyObject) {
         dismissViewControllerAnimated(true, completion: nil)
    }
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("Completed login")
        fetchProfile()
        PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken()) { (user, error) in
            if let user = user {
                print("Logged in into Parse with user \(user)")
                //let id = self.userDict!.valueForKey("fbId") as! String
                //user.setObject(id, forKey: "fbId")
                //let firstName = self.userDict!.valueForKey("first_name") as! String
                //let lastName = self.userDict!.valueForKey("last_name") as! String
                //user.setObject(firstName, forKey: "firstName")
                //user.setObject(lastName, forKey: "lastName")
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            } else if let error = error {
                print("Failed to log in into Parse with error \(error)")
            }
        }
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    func tap(gesture: UITapGestureRecognizer) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }

    @IBAction func onLogin(sender: AnyObject) {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        
        PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                self.fetchProfile()
                print("User logged in successfully")
                self.performSegueWithIdentifier("loginSegue", sender: nil)
                
            } else {
                print(error!.localizedDescription)
                
                // display view controller that needs to shown after successful login
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
