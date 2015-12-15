//
//  RiderViewController.swift
//  ACUberSwift
//
//  Created by Adriana Carelli on 15/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import MapKit


class RiderViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var callUberButton: UIButton!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        
        if segue.identifier == "logoutRider"{
            
            PFUser.logOut()
            let currentUser = PFUser.currentUser()
            
            print(currentUser)
        }
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
   
   
    @IBAction func callUber(sender: AnyObject) {
        
        
        
        let titleValueString = self.callUberButton.currentTitle!
        if titleValueString == "Call An Uber"{
            
            let riderRequest = PFObject(className: "riderRequest")
            riderRequest["username"] = PFUser.currentUser()?.username
            riderRequest["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            riderRequest.saveInBackgroundWithBlock{
                (success: Bool, error: NSError? ) -> Void in
                
                self.callUberButton.setTitle("Cancel Uber", forState: UIControlState.Normal)
            }
            
        }else{
           
            let query = PFQuery(className: "riderRequest")
            query.whereKey("username", equalTo: (PFUser.currentUser()!.username)!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    if let objects = objects  {
                        for object in objects {
                            object.deleteInBackground()
                            self.callUberButton.setTitle("Call An Uber", forState: UIControlState.Normal)
                        }
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        
        print("location = \(locValue.latitude) \(locValue.longitude)")
        
        let location = locations.last! as CLLocation
        
        latitude = locValue.latitude
        longitude = locValue.longitude
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        self.mapView.removeAnnotations(mapView.annotations)
        
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = center
        objectAnnotation.title = "My Location"
        self.mapView.addAnnotation(objectAnnotation)
    }
    
    

}
