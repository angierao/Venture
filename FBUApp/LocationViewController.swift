//
//  LocationViewController.swift
//  FBUApp
//
//  Created by Jedidiah Akano on 7/7/16.
//  Copyright © 2016 Kelly Lampotang. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import CoreLocation

protocol LocationsViewControllerDelegate : class {
    func locationsPickedLocation(latitude: NSNumber, longitude: NSNumber, sentLocation: String, address: [NSString], city: String, venueId: String)
    
}

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cityBeingUsedLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    var image: UIImage?
    let locationManager = CLLocationManager()
    var currentLocation = ""
    
    let CLIENT_ID = "VM3U2MOM4P4IOVBQMZW5NSQH1MJEANGW51YA4SVMW4JLAEBH"
    let CLIENT_SECRET = "5FHY2RUJVEW2YRHJ3J53XN5J0U2HUY5KNQMFSCHJVMQPMDUC"
    weak var delegate : LocationsViewControllerDelegate!
    
    var results: NSArray = []
    var near: AnyObject?
    let fourSquareInfo = FourSquareClient()
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        locationSearchBar.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationViewController.reloadTableData(_:)), name: "reload", object: nil)
        let currentUser = PFUser.currentUser()
        near = currentUser!["currLoc"]
        if(near == nil)
        {
            near = "San Francisco, CA, United States"
        }
        if(currentUser!["defaultCity"] != nil && currentUser!["defaultCity"] as! String != "")
        {
            near = currentUser!["defaultCity"] as! String
        }
        cityBeingUsedLabel.text = near as? String
        cityBeingUsedLabel.font = UIFont (name: "HelveticaNeue-Thin", size: 11)
        backButton.titleLabel!.font = UIFont (name: "HelveticaNeue-Thin", size: 15)

    }
    
        func reloadTableData(notification: NSNotification) {
        tableView.reloadData()
    }
    @IBAction func goBackToUploadTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationViewCell") as! LocationViewCell
        cell.location = results[indexPath.row] as! NSDictionary
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = NSString(string: searchBar.text!).stringByReplacingCharactersInRange(range, withString: text)
        /*fourSquareInfo.*/fetchLocations(newText)
    
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        /*fourSquareInfo.*/fetchLocations(searchBar.text!)
        
    }
    
    func fetchLocations(query: String) {
        let baseUrlString = "https://api.foursquare.com/v2/venues/search?"
        let queryString = "client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&v=20141020&near=\(near!)&query=\(query)"
        print(queryString)
        let url = NSURL(string: baseUrlString + queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        let request = NSURLRequest(URL: url)
        //print(url)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                    //NSLog("response: \(responseDictionary)")
                    self.results = responseDictionary.valueForKeyPath("response.venues") as! NSArray
                    self.tableView.reloadData()
                }
            }
        });
        task.resume()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = results[indexPath.row] as! NSDictionary
        print(location)
        let lat = location.valueForKeyPath("location.lat") as! NSNumber
        let long = location.valueForKeyPath("location.lng") as! NSNumber
        let sentLocation = location["name"] as? String
        let address = location.valueForKeyPath("location.formattedAddress") as! [NSString]
        let justCity = location.valueForKeyPath("location.city") as? String
        let justState = location.valueForKeyPath("location.state") as? String
        let justCountry = location.valueForKeyPath("location.country") as? String
        let city = justCity! + ", " + justState! + ", " + justCountry!
        let venueId = location.valueForKey("id") as? String
        delegate.locationsPickedLocation(lat, longitude: long, sentLocation: sentLocation!, address: address, city: city, venueId: venueId!)
        dismissViewControllerAnimated(true, completion: nil)
        
    }

}
