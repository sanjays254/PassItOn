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
        self.homeTableView.rowHeight = 70
        
        
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

        
        //set region
        let span = MKCoordinateSpanMake(0.007, 0.007)
        
        self.homeMapView.region = MKCoordinateRegionMake(self.currentLocation.coordinate, span)
        
        self.homeMapView.showsUserLocation = true
        self.homeMapView.showsPointsOfInterest = false
        

        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let testEmail = "nchlsfung@gmail.com"
        let testPassword = "password"
        let testName = "Nick"
        
        print("email: \(testEmail), password: \(testPassword), username: \(testName)")
        
        // AuthenticationHelper.register(withEmail: testEmail, password: testPassword, username: testName)
        AuthenticationHelper.login(withEmail: testEmail, password: testPassword)
        
        ReadFirebaseData.read()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
     
        homeTableView.reloadData()
        for any in AppData.sharedInstance.onlineItems {
            print("\n\nCoordinate: \(any.coordinate)\nLocation: \(any.location)")
        }
        self.homeMapView.addAnnotations(AppData.sharedInstance.onlineItems)
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
            homeTableView.reloadData()
        }
    }
    
    //tableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.sharedInstance.onlineItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(UINib(nibName: "ItemHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "itemHomeTableViewCellID")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemHomeTableViewCellID") as! ItemHomeTableViewCell
        
        cell.itemTitleLabel.text = AppData.sharedInstance.onlineItems[indexPath.row].name
        cell.itemQualityLabel.text = AppData.sharedInstance.onlineItems[indexPath.row].quality.rawValue
        let destinationLocation: CLLocation = CLLocation(latitude: AppData.sharedInstance.onlineItems[indexPath.row].location.latitude, longitude: AppData.sharedInstance.onlineItems[indexPath.row].location.longitude)
        
        let distance = (destinationLocation.distance(from: self.currentLocation)/1000)
        
        cell.itemDistanceLabel.text = String(format: "%.2f", distance) + " kms away"
        
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

