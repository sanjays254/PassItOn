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
    
    let myNotificationKey = "theNotificationKey"
    let myDowloadNotificationKey = "myDownloadNotificationKey"

    var currentLocation: CLLocation!
    var locationManager: CLLocationManager!
    
    var compassButton: UIButton!
    
    var mapListSegmentedControl: UISegmentedControl!
    @IBOutlet weak var wantedAvailableSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var homeMapView: MKMapView!
    @IBOutlet weak var homeTableView: UITableView!
    
    
    var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homeTableView.delegate = self
        self.homeTableView.dataSource = self
        self.homeTableView.rowHeight = 70
        
        self.homeTableView.refreshControl = UIRefreshControl()
        self.homeTableView.refreshControl?.backgroundColor = UIColor.blue
        self.homeTableView.refreshControl?.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
        
        
        //let userUpdateNotification = Notification.Name("userUpdate")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: myNotificationKey), object: nil, queue: nil, using: catchNotification)
        
        
        //delegating the mapView
        self.homeMapView.delegate = MapViewDelegate.theMapViewDelegate
        MapViewDelegate.theMapViewDelegate.theMapView = homeMapView
        MapViewDelegate.theMapViewDelegate.setMapRegion()
        
        homeMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "itemMarkerView")

        
        //compassButton
        compassButton = UIButton(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
        compassButton.setImage(#imageLiteral(resourceName: "compass"), for: UIControlState.normal)
       // compassButton.addTarget(self, action: #selector(MapViewDelegate.theMapViewDelegate.setMapRegion), for: .touchUpInside)
        homeMapView.addSubview(compassButton)
        
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        
        let trailingConstraint = NSLayoutConstraint(item: compassButton, attribute: .trailing, relatedBy: .equal, toItem: homeMapView, attribute: .trailing , multiplier: 1, constant: -10)
        let bottomConstraint = NSLayoutConstraint(item: compassButton, attribute: .bottom, relatedBy: .equal, toItem: homeMapView, attribute: .bottom , multiplier: 1, constant: -10)
        let widthConstraint = NSLayoutConstraint(item: compassButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute , multiplier: 1, constant: 30)
        let heightConstraint = NSLayoutConstraint(item: compassButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute , multiplier: 1, constant: 30)
        
        NSLayoutConstraint.activate([trailingConstraint, bottomConstraint, widthConstraint, heightConstraint])
        
        self.compassButton.layer.cornerRadius = self.compassButton.frame.size.width / 2.0
        self.compassButton.layer.masksToBounds = false
        self.compassButton.layer.shadowOffset = CGSize.init(width: 0, height: 2.0)
        self.compassButton.layer.shadowColor = (UIColor.black).cgColor
        self.compassButton.layer.shadowOpacity = 0.5
        self.compassButton.layer.shadowRadius = 1.0
        
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
        
//        DispatchQueue.global(qos: .background).async {
// 
            ReadFirebaseData.read()
            print("Downloading")
            
//            DispatchQueue.main.async {
//
//                self.homeMapView.addAnnotations(AppData.sharedInstance.onlineItems)
//                print("Downlaoded")
//
//            }
//        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addAnnotationsWhenFinishedDownloadingData),
            name: NSNotification.Name(rawValue: myDowloadNotificationKey),
            object: nil)

        
    }
    
    @objc func addAnnotationsWhenFinishedDownloadingData(notification: NSNotification){
        self.homeMapView.addAnnotations(AppData.sharedInstance.onlineItems)
         print("Downlaoded")
    }
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
     
        homeTableView.reloadData()

        self.homeMapView.addAnnotations(AppData.sharedInstance.onlineItems)
    }
    
    
    func catchNotification(notification:Notification) -> Void {
        guard let name = notification.userInfo!["name"] as? Item else { return }
        self.showItemDetail(item: name)
        
       // FirstVCLabel.text = "My name, \(name) has been passed! 😄"
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
        
        cell.itemDistanceLabel.text = String(format: "%.2f", distance) + " kms"
        
        return cell
    }
    
    @objc func refreshTableData(sender: AnyObject) {
        
        //ReadFirebaseData.read()
        
        DispatchQueue.main.async {
            //Update tableView once read
            
        }
        
        if((self.homeTableView.refreshControl) != nil){
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
            let title = String("Last update: \(dateFormatter.string(from: Date()))")
            let attributesDict = [NSAttributedStringKey.foregroundColor: UIColor.white]
            let attributedTitle = NSAttributedString(string: title, attributes: attributesDict)
            self.homeTableView.refreshControl?.attributedTitle = attributedTitle
        }
        
        self.homeTableView.reloadData()
        self.homeTableView.refreshControl?.endRefreshing()
        
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

    
    

    
    @objc func showItemDetail(item: Item){

        
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            ])
        
        containerView.alpha = 1
        containerView.backgroundColor = UIColor.clear
        
    
        
        let detailViewController = ItemDetailViewController()
        detailViewController.currentItem = item
        addChildViewController(detailViewController)
        detailViewController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(detailViewController.view)
       
       
        detailViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        NSLayoutConstraint.activate([
            detailViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            detailViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            detailViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            detailViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
        detailViewController.didMove(toParentViewController: self)
        
        
        
        
        
        
       // detailViewController.didMove(toParentViewController: self)
        
//        detailViewController.modalPresentationStyle = UIModalPresentationStyle.currentContext
//        detailViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//        self.present(detailViewController, animated: true, completion: nil)
//
//        addChildViewController(detailViewController)
//        detailViewController.view.translatesAutoresizingMaskIntoConstraints = false
        //present(ItemDetailViewController(), animated: true, completion: nil)
//        detailContainerView.addSubview((detailViewController.view)!)
//
//        NSLayoutConstraint.activate([
//            detailViewController.view.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor),
//            detailViewController.view.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor),
//            detailViewController.view.topAnchor.constraint(equalTo: detailContainerView.topAnchor),
//            detailViewController.view.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor)
//            ])
//
//        detailViewController.didMove(toParentViewController: self)



    }

}

