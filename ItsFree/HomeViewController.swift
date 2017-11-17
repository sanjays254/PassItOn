//
//  ViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-16.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

// Nicholas Fung


import UIKit
import MapKit



class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate {

    var currentLocation: CLLocation!
    var locationManager: CLLocationManager!
    
    var mapListSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var wantedAvailableSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var homeMapView: MKMapView!
    
    @IBOutlet weak var homeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeTableView.delegate = self
        self.homeTableView.delegate = self
        self.homeMapView.delegate = self
        
        self.mapListSegmentedControl = UISegmentedControl(items: ["Map", "List"])
        self.navigationItem.titleView = mapListSegmentedControl
        self.mapListSegmentedControl.selectedSegmentIndex = 0
        self.mapListSegmentedControl.addTarget(self, action: #selector(mapListSegmentAction), for: .valueChanged)
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        self.getLocation()
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemsCellID", for: indexPath)
        
        return cell
    }
    
    //map/list segmenetd control
    @objc func mapListSegmentAction(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            self.view.bringSubview(toFront: homeMapView)
        }
        else if sender.selectedSegmentIndex == 1{
            self.view.bringSubview(toFront: homeTableView)
        }
        
    }
    
    //mapView methods
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        self.currentLocation = self.locationManager.location
        
        //if we are at default Apple coordinate (0,0), then update region
        let lat: Float = Float(self.homeMapView.region.center.latitude)
        let long: Float = Float(self.homeMapView.region.center.longitude)
        
        if (lat == 0 && long == 0){
            
            let span = MKCoordinateSpanMake(0.007, 0.007)
            self.homeMapView.region = MKCoordinateRegionMake(self.currentLocation.coordinate, span)
            
        }
    }
    
    
    func getLocation() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        //get current position
        self.currentLocation = self.locationManager.location
        
        //set region
        let span = MKCoordinateSpanMake(0.007, 0.007)
        self.homeMapView.region = MKCoordinateRegionMake(self.currentLocation.coordinate, span)
        
        self.homeMapView.showsUserLocation = true
        self.homeMapView.showsPointsOfInterest = false
        
    }
    
    

    
    
    //segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "postSegue"){
          
        }
        
    }
  
}

