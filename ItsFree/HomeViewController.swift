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
        self.homeTableView.dataSource = self
        
        //delegating the mapView
        self.homeMapView.delegate = MapViewDelegate.theMapViewDelegate
        MapViewDelegate.theMapViewDelegate.theMapView = homeMapView
        MapViewDelegate.theMapViewDelegate.setMapRegion()
        
        //mapList Segment Control setup
        self.mapListSegmentedControl = UISegmentedControl(items: ["Map", "List"])
        self.navigationItem.titleView = mapListSegmentedControl
        self.mapListSegmentedControl.selectedSegmentIndex = 0
        self.mapListSegmentedControl.addTarget(self, action: #selector(mapListSegmentAction), for: .valueChanged)
        
        self.currentLocation =  LocationManager.theLocationManager.getLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //mapList segmented control
    @objc func mapListSegmentAction(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            self.view.bringSubview(toFront: homeMapView)
        }
        else if sender.selectedSegmentIndex == 1 {
            self.view.bringSubview(toFront: homeTableView)
        }
    }
    
    //tableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemsCellID", for: indexPath)
        
        return cell
    }
    

    //segues

    @IBAction func postItem(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "postSegue", sender: self)
    }
    

    //location authorization
    func presentLocationAlert(){
        let alert = UIAlertController(title: "Your title", message: "GPS access is restricted. In order to use tracking, please enable GPS in the Settigs app under Privacy, Location Services.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
            print("")
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    
}

