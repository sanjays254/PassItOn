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
import FirebaseStorage


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, UINavigationControllerDelegate {
    
    let mySelectedItemNotificationKey = "theNotificationKey"
    let myDowloadCompletedNotificationKey = "myDownloadNotificationKey"
    let filterAppliedKey = "filterAppliedKey"

    var currentLocation: CLLocation!
    var locationManager: CLLocationManager!
    
    var compassButton: UIButton!
    
    var mapListSegmentedControl: UISegmentedControl!
    @IBOutlet weak var wantedAvailableSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var homeMapView: MKMapView!
    @IBOutlet weak var homeTableView: UITableView!
    
    var itemDetailContainerView: UIView!
    var filterContainerView: UIView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wantedAvailableSegmentedControl.selectedSegmentIndex = 1
        
        //delegating the tableView
        self.homeTableView.delegate = self
        self.homeTableView.dataSource = self
        self.homeTableView.rowHeight = 70
        
        self.homeTableView.refreshControl = UIRefreshControl()
        self.homeTableView.refreshControl?.backgroundColor = UIProperties.sharedUIProperties.purpleColour
        self.homeTableView.refreshControl?.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
        
        //delegating the mapView
        self.homeMapView.delegate = MapViewDelegate.theMapViewDelegate
        MapViewDelegate.theMapViewDelegate.theMapView = homeMapView
        setInitalMapRegion()
        

        let leaderboardImage = UIImage(named: "leaderboard")?.withRenderingMode(.alwaysTemplate)
    
        let leaderboardButton  = UIButton(type: .custom)
        leaderboardButton.setImage(leaderboardImage, for: .normal)
        leaderboardButton.tintColor = UIProperties.sharedUIProperties.lightGreenColour
        leaderboardButton.addTarget(self, action: #selector(leaderboardButtonAction), for: .touchUpInside)
        leaderboardButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        leaderboardButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let leaderboardBarButton = UIBarButtonItem(customView: leaderboardButton)
        self.navigationItem.leftBarButtonItem = leaderboardBarButton
        
        
        let addPostBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(postItem))
        self.navigationItem.rightBarButtonItem = addPostBarButton
        
        
        setupCompassButton()
        setupMapListSegmentedControl()
        
        
        ReadFirebaseData.readOffers(category: nil)
        ReadFirebaseData.readRequests(category: nil)
        ReadFirebaseData.readUsers()
   
       // NotificationCenter.default.addObserver(self, selector: #selector(self.refreshData), name: NSNotification.Name(rawValue: filterAppliedKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.addAnnotationsWhenFinishedDownloadingData), name: NSNotification.Name(rawValue: myDowloadCompletedNotificationKey), object: nil)

        homeMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "itemMarkerView")
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: mySelectedItemNotificationKey), object: nil, queue: nil, using: catchNotification)
        
        
    }
    
    fileprivate func getLocation() -> CLLocation {
        self.currentLocation =  LocationManager.theLocationManager.getLocation()
        return self.currentLocation
    }
    
    fileprivate func setupMapListSegmentedControl() {

        self.mapListSegmentedControl = UISegmentedControl(items: ["Map", "List"])
        self.navigationItem.titleView = mapListSegmentedControl
        self.mapListSegmentedControl.selectedSegmentIndex = 0
        self.mapListSegmentedControl.addTarget(self, action: #selector(mapListSegmentAction), for: .valueChanged)
    }
 
    fileprivate func setupCompassButton() {
  
        compassButton = UIButton(type: .system)
        compassButton.frame = CGRect(x: 25, y: 25, width: 20, height: 20)
        compassButton.setImage(#imageLiteral(resourceName: "compass"), for: UIControlState.normal)
        compassButton.addTarget(self, action: #selector(setMapRegion), for: .touchUpInside)
        homeMapView.addSubview(compassButton)
        
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        
        let trailingConstraint = NSLayoutConstraint(item: compassButton, attribute: .trailing, relatedBy: .equal, toItem: homeMapView, attribute: .trailing , multiplier: 1, constant: -10)
        let bottomConstraint = NSLayoutConstraint(item: compassButton, attribute: .bottom, relatedBy: .equal, toItem: homeMapView, attribute: .bottom , multiplier: 1, constant: -10)
        let widthConstraint = NSLayoutConstraint(item: compassButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute , multiplier: 1, constant: 40)
        let heightConstraint = NSLayoutConstraint(item: compassButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute , multiplier: 1, constant: 40)
        
        NSLayoutConstraint.activate([trailingConstraint, bottomConstraint, widthConstraint, heightConstraint])
        
        self.compassButton.layer.backgroundColor = UIProperties.sharedUIProperties.blackColour.cgColor
        self.compassButton.tintColor = UIProperties.sharedUIProperties.lightGreenColour
        self.compassButton.layer.cornerRadius = compassButton.frame.width/2
        self.compassButton.layer.masksToBounds = false
        self.compassButton.layer.shadowOffset = CGSize.init(width: 0, height: 2.0)
        self.compassButton.layer.shadowColor = (UIColor.black).cgColor
        self.compassButton.layer.shadowOpacity = 0.5
        self.compassButton.layer.shadowRadius = 1.0
    }
    
    
    @objc func setMapRegion(){
        MapViewDelegate.theMapViewDelegate.setMapRegion()
    }
    
    @objc func setInitalMapRegion(){
        MapViewDelegate.theMapViewDelegate.setInitialMapRegion()
        
    }
    
    


    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
        self.homeTableView.reloadData()
    }
    
    //receives info from mapViewDelegate about which itemAnnotation was clicked on
    func catchNotification(notification:Notification) -> Void {
        guard let name = notification.userInfo!["name"] as? Item else { return }
        self.showItemDetail(item: name)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.homeTableView.reloadData()
    }
    
//    @objc func refreshData(){
//        if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
//            self.homeMapView.removeAnnotations(AppData.sharedInstance.onlineOfferedItems)
//            self.homeMapView.addAnnotations(AppData.sharedInstance.onlineRequestedItems)
//            homeTableView.reloadData()
//        }
//        else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
//            self.homeMapView.removeAnnotations(AppData.sharedInstance.onlineRequestedItems)
//            self.homeMapView.addAnnotations(AppData.sharedInstance.onlineOfferedItems)
//            homeTableView.reloadData()
//        }
//
//    }
    
    //wantedAvailable segmenetd control
    @IBAction func changedWantedAvailableSegmnent(_ sender: UISegmentedControl) {
        
        if(sender.selectedSegmentIndex == 0){
            self.homeMapView.removeAnnotations(AppData.sharedInstance.onlineOfferedItems)
            self.homeMapView.addAnnotations(AppData.sharedInstance.onlineRequestedItems)
            homeTableView.reloadData()
        }
        else if (sender.selectedSegmentIndex == 1){
            self.homeMapView.removeAnnotations(AppData.sharedInstance.onlineRequestedItems)
            self.homeMapView.addAnnotations(AppData.sharedInstance.onlineOfferedItems)
            homeTableView.reloadData()
        }
        
    }
    @objc func addAnnotationsWhenFinishedDownloadingData(notification: NSNotification){
        
        self.homeMapView.removeAnnotations(homeMapView.annotations)
        
        if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
            
            self.homeMapView.addAnnotations(AppData.sharedInstance.onlineRequestedItems)
        }
        else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
            
            self.homeMapView.addAnnotations(AppData.sharedInstance.onlineOfferedItems)
        }
        
        
    }
    
    
    @IBAction func filterTapped(_ sender: UIBarButtonItem) {
        
        

        let filterViewController = FilterTableViewController()
        self.navigationController?.pushViewController(filterViewController, animated: true)
       
       
        filterViewController.view.translatesAutoresizingMaskIntoConstraints = false
  
        filterViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)

    }
    
    
    
    //mapList segmented control
    @objc func mapListSegmentAction(sender: UISegmentedControl) {
        
        if(!self.childViewControllers.isEmpty){
        let itemDetailViewController = self.childViewControllers[0] as! ItemDetailViewController
        itemDetailViewController.removeFromParentViewController()
            itemDetailContainerView.removeFromSuperview()
        }
        
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
        
        if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
            return AppData.sharedInstance.onlineRequestedItems.count
        }
        else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
            return AppData.sharedInstance.onlineOfferedItems.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(UINib(nibName: "ItemHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "itemHomeTableViewCellID")
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemHomeTableViewCellID") as! ItemHomeTableViewCell
        let storageRef = Storage.storage().reference()
        let sourceArray:[Item]!
        if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
            sourceArray = AppData.sharedInstance.onlineRequestedItems
            cell.itemTitleLabel.text = AppData.sharedInstance.onlineRequestedItems[indexPath.row].name
            cell.itemQualityLabel.text = AppData.sharedInstance.onlineRequestedItems[indexPath.row].quality.rawValue
            let destinationLocation: CLLocation = CLLocation(latitude: AppData.sharedInstance.onlineRequestedItems[indexPath.row].location.latitude, longitude: AppData.sharedInstance.onlineRequestedItems[indexPath.row].location.longitude)
            
            let distance = (destinationLocation.distance(from: getLocation())/1000)
            
            cell.itemDistanceLabel.text = String(format: "%.2f", distance) + " kms"

            cell.itemImageView.sd_setImage(with: storageRef.child(AppData.sharedInstance.onlineRequestedItems[indexPath.row].photos[0]), placeholderImage: UIImage.init(named: "placeholder"))
        }
        else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
            sourceArray = AppData.sharedInstance.onlineOfferedItems
            cell.itemTitleLabel.text = AppData.sharedInstance.onlineOfferedItems[indexPath.row].name
            cell.itemQualityLabel.text = AppData.sharedInstance.onlineOfferedItems[indexPath.row].quality.rawValue
            let destinationLocation: CLLocation = CLLocation(latitude: AppData.sharedInstance.onlineOfferedItems[indexPath.row].location.latitude, longitude: AppData.sharedInstance.onlineOfferedItems[indexPath.row].location.longitude)
            
            let distance = (destinationLocation.distance(from: getLocation())/1000)
            
            cell.itemDistanceLabel.text = String(format: "%.2f", distance) + " kms"
            cell.itemImageView.sd_setImage(with: storageRef.child(AppData.sharedInstance.onlineOfferedItems[indexPath.row].photos[0]), placeholderImage: UIImage.init(named: "placeholder"))

        }
        
        
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
        
//        self.homeMapView.removeAnnotations(AppData.sharedInstance.onlineOfferedItems)
//        self.homeMapView.addAnnotations(AppData.sharedInstance.onlineRequestedItems)
        
    }

    //segues
    @objc func postItem() {
        performSegue(withIdentifier: "postSegue", sender: self)
    }
    
    @IBAction func toProfile(_ sender: Any) {
        performSegue(withIdentifier: "toProfileSegue", sender: self)
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



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let itemToShow: Item
        
        switch(wantedAvailableSegmentedControl.selectedSegmentIndex){
        case 0:  itemToShow = AppData.sharedInstance.onlineRequestedItems[indexPath.row]
        case 1:  itemToShow = AppData.sharedInstance.onlineOfferedItems[indexPath.row]
        default:
            return
        }
        
        
        //mapListSegmentedControl.sendActions(for: UIControlEvents.valueChanged)
        mapListSegmentedControl.selectedSegmentIndex = 0
        mapListSegmentedControl.sendActions(for: UIControlEvents.valueChanged)
        //view.bringSubview(toFront: homeMapView)
        
        homeMapView.selectAnnotation(itemToShow, animated: true)
        
        let span = MKCoordinateSpanMake(0.007, 0.007)

        homeMapView.setRegion(MKCoordinateRegionMake(itemToShow.coordinate, span) , animated: true)
        //showItemDetail(item: itemToShow)
    }
    
    @objc func showItemDetail(item: Item){

        //make the container view
        itemDetailContainerView = UIView()
        itemDetailContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(itemDetailContainerView)
        
        NSLayoutConstraint.activate([
            itemDetailContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            itemDetailContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            itemDetailContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            itemDetailContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 30)
            ])
        
        itemDetailContainerView.alpha = 1
        itemDetailContainerView.backgroundColor = UIColor.clear
        
        //make the childViewController and add it into the containerView
        let detailViewController = ItemDetailViewController()
        detailViewController.currentItem = item
        addChildViewController(detailViewController)
        detailViewController.view.translatesAutoresizingMaskIntoConstraints = false
        itemDetailContainerView.addSubview(detailViewController.view)
        
        let yPoint = (self.navigationController?.navigationBar.frame.height)! + (UIApplication.shared.statusBarFrame.size.height)
        
//        UIView.animate(withDuration: 0.5, animations: {
//            self.itemDetailView.frame = CGRect(x: 0, y:yPoint, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
//
//        }, completion: {(finished: Bool) in
//
//        })
       
        detailViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height+50)
        
        NSLayoutConstraint.activate([
            detailViewController.view.leadingAnchor.constraint(equalTo: itemDetailContainerView.leadingAnchor),
            detailViewController.view.trailingAnchor.constraint(equalTo: itemDetailContainerView.trailingAnchor),
            detailViewController.view.topAnchor.constraint(equalTo: itemDetailContainerView.topAnchor),
            detailViewController.view.bottomAnchor.constraint(equalTo: itemDetailContainerView.bottomAnchor)
            ])
        
        detailViewController.didMove(toParentViewController: self)
    }
    
    
     @objc func leaderboardButtonAction() {
  
        performSegue(withIdentifier: "leaderboardSegue", sender: self)
    }
    
}

