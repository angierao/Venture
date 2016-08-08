//
//  CitiesViewController.swift
//  FBUApp
//
//  Created by Kelly Lampotang on 7/8/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

protocol CitiesViewControllerDelegate : class {
    func cityPicked(city: String)
}

class CitiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    weak var delegate : CitiesViewControllerDelegate!

    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var tableView: UITableView!
    
    let API_KEY = "AIzaSyDl7xbKCu609eOsFo4zMsfWGnU5Tk_45OY"
    //@IBOutlet weak var locSearchBar: UISearchBar!
    //@IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var locSearchBar: UISearchBar!
    @IBOutlet weak var backgroundView: UIImageView!
    var results: NSArray = []
    var cityTyped = ""
    var locationChosen = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = UIColor.clearColor()
        
        locSearchBar.placeholder = "Search for a city"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clearColor()
        locSearchBar.delegate = self
        backButton.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 15)
        
        let imageToBlur = CIImage(image: UIImage(named: "ny_3-4")!)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        blurfilter!.setValue(15, forKey: "inputRadius")
        let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
        var blurredImage = UIImage(CIImage: resultImage)
        let cropped:CIImage=resultImage.imageByCroppingToRect(CGRectMake(0, 0,imageToBlur!.extent.size.width, imageToBlur!.extent.size.height))
        blurredImage = UIImage(CIImage: cropped)
        //backgroundView.image = blurredImage
        
        self.backgroundView.image = UIImage()
        
        //backgroundView.alpha = 0.4
        backgroundView.layer.cornerRadius = backgroundView.frame.width/32
        backgroundView.clipsToBounds = true
        
        locSearchBar.clipsToBounds = true
        backButton.clipsToBounds = true
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = NSString(string: searchBar.text!).stringByReplacingCharactersInRange(range, withString: text)
        cityTyped = newText
        fetchCities(cityTyped)
        
        return true
    }
    @IBAction func backTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        fetchCities(cityTyped)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CityViewCell") as! CityViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        cell.cityLabel.text = (results[indexPath.row]).valueForKey("description") as? String
        cell.cityLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        //print((results[indexPath.row]).description)
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func fetchCities(query: String) {
        print("being called")
        let queryString = cityTyped.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(queryString)&types=(cities)&key=\(API_KEY)")
        
        let request = NSURLRequest(URL: url!)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                    self.results = responseDictionary.valueForKeyPath("predictions") as! NSArray
                    //print(self.results)
                    self.tableView.reloadData()
                }
            }
        });
        task.resume()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        locationChosen = (results[indexPath.row]).valueForKey("description") as! String
        print(locationChosen)
        if(PFUser.currentUser() != nil)
        {
            let currUser = PFUser.currentUser()
            delegate.cityPicked(locationChosen)
            currUser!.setObject(locationChosen, forKey: "defaultCity")
            currUser!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                print(currUser!["defaultCity"] as! String)
            })
        }
        else
        {
            delegate.cityPicked(locationChosen)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    
}
