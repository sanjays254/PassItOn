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

public var offerRequestBool: Bool!

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, UINavigationControllerDelegate, UISearchBarDelegate, NotificationDelegate, LoggedOutDelegate {
    
    let mySelectedItemNotificationKey = "mySelectedItemNotificationKey"
    let myOffersDownloadedNotificationKey = "myOffersDownloadedNotificationKey"
    let myRequestsDownloadedNotificationKey = "myRequestsDownloadedNotificationKey"
    let filterAppliedKey = "filterAppliedKey"
    
    var offersDownloaded: Bool!
    var requestsDownloaded: Bool!
    
    weak var currentLocation: CLLocation!
    weak var locationManager: CLLocationManager!
    
    var compassButton: UIButton!
    var mapListSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var wantedAvailableSegmentedControl: UISegmentedControl!
    @IBOutlet weak var newPostButton: UIBarButtonItem!
    @IBOutlet weak var homeMapView: MKMapView!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var homeTableViewTopConstraint: NSLayoutConstraint!
    
    var itemDetailContainerView: UIView!
    var filterContainerView: UIView!
    
    var currentItemIndexPath: IndexPath!
    var lastItemSelected: Item!
    
    var currentCategory: ItemCategory?
  
    var searchActive : Bool = false
    var searchApplied : Bool = false
    var filteredOfferedItems:[Item]!
    var filteredRequestedItems:[Item]!
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wantedAvailableSegmentedControl.selectedSegmentIndex = 1
        offerRequestBool = true
        
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
        homeMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "itemMarkerView")
        
        //homeMapView.register(ItemClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)

        
        setupSearchBar()
        setupPostButton()
        setupSearchButton()
        setupCompassButton()
        setupMapListSegmentedControl()
        profileButton.isEnabled = false
       
        BusyActivityView.show(inpVc: self)
        
        setupNotifications()
        
        ReadFirebaseData.readOffers(category: nil)
        ReadFirebaseData.readRequests(category: nil)
     
        readCurrentUser()
    
        if let firstTimeUserUnwrapped = firstTimeUser{
            if (firstTimeUserUnwrapped){
                presentAlertIfFirstTime()
            }
        }
    }
    func readCurrentUser(){
        
        profileButton.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(allowProfileAccess), name: NSNotification.Name(rawValue: "myUserDownloadNotificationKey"), object: nil)
        
        ReadFirebaseData.readCurrentUser()
    }
    
    
    func goToLoginVC() {
        
        if (UIApplication.shared.keyWindow?.rootViewController as? LoginViewController) != nil {
            self.navigationController?.popToRootViewController(animated: true)
            
        }
        else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginViewController")
    
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    
    func setupSearchBar(){
        
        searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0)
        searchBar.delegate = self
        searchBar.keyboardAppearance = .dark
        filteredOfferedItems = []
        filteredRequestedItems = []
    }
    
    func presentAlertIfFirstTime(){
        
        let firstTimeUseAlert = UIAlertController(title: "Welcome to Pass It On", message: "Remember! Free items only!", preferredStyle: .alert)
        let coolAction = UIAlertAction(title: "Sounds good", style: .default, handler: nil)
        firstTimeUseAlert.addAction(coolAction)
        
        present(firstTimeUseAlert, animated: true, completion: nil)
    }
    
    
    func setupPostButton(){
        
        let addPostBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(postItem))
        self.navigationItem.rightBarButtonItem = addPostBarButton
        addPostBarButton.tintColor = UIProperties.sharedUIProperties.whiteColour
    }
    
    func setupSearchButton(){
        
        let searchButton  = UIButton(type: .system)
        let searchImage = UIImage(named: "search")?.withRenderingMode(.alwaysTemplate)
        
        searchButton.setImage(searchImage, for: .normal)
        
        searchButton.tintColor = UIProperties.sharedUIProperties.whiteColour
        searchButton.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        searchButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        self.navigationItem.leftBarButtonItem = searchBarButton
        
    }
    
    @objc func searchButtonAction(){
        
        view.bringSubview(toFront: searchBar)
        
        if (searchBarHeightConstraint.constant == 45){
            UIView.animate(withDuration: 0.5, animations: {
                self.searchBarHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            }, completion: {(finished: Bool) in
                self.searchBar.resignFirstResponder()
            })
        }
        
        else if (searchBarHeightConstraint.constant == 0){
       
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBarHeightConstraint.constant = 45
            
             self.view.layoutIfNeeded()
            
        }, completion: {(finished: Bool) in
            self.searchBar.becomeFirstResponder()
        })
        }
    }
    
    func setupLeaderboardButton(){
        let leaderboardImage = UIImage(named: "leaderboard")?.withRenderingMode(.alwaysTemplate)
        
        let leaderboardButton  = UIButton(type: .custom)
        leaderboardButton.setImage(leaderboardImage, for: .normal)
        leaderboardButton.tintColor = UIProperties.sharedUIProperties.whiteColour
        leaderboardButton.addTarget(self, action: #selector(leaderboardButtonAction), for: .touchUpInside)
        leaderboardButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        leaderboardButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let leaderboardBarButton = UIBarButtonItem(customView: leaderboardButton)
        self.navigationItem.leftBarButtonItem = leaderboardBarButton
    }
    
    
    fileprivate func setupMapListSegmentedControl() {
        
        self.mapListSegmentedControl = UISegmentedControl(items: ["Map", "List"])
        
        self.navigationItem.titleView = mapListSegmentedControl
        self.mapListSegmentedControl.tintColor = UIProperties.sharedUIProperties.lightGreenColour
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
    
    //location methods
    fileprivate func getLocation() -> CLLocation {
        self.currentLocation =  LocationManager.theLocationManager.getLocation()
        return self.currentLocation
    }
    
    @objc func setMapRegion(){
        MapViewDelegate.theMapViewDelegate.theMapView = homeMapView
        MapViewDelegate.theMapViewDelegate.setMapRegion()
    }
    
    @objc func setInitalMapRegion(){
        MapViewDelegate.theMapViewDelegate.setInitialMapRegion()
    }
    
    //location authorization
    func presentLocationAlert(){
        let alert = UIAlertController(title: "Your title", message: "GPS access is restricted. In order to use tracking, please enable GPS in the Settigs app under Privacy, Location Services.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func sortTableView()
    {
        AppData.sharedInstance.onlineOfferedItems.sort(by:
            { $0.distance(to: getLocation()) < $1.distance(to: getLocation())})
        
        AppData.sharedInstance.onlineRequestedItems.sort(by:
            { $0.distance(to: getLocation()) < $1.distance(to: getLocation())})
        
        self.homeTableView.reloadData();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        MapViewDelegate.theMapViewDelegate.theMapView = homeMapView

    }
    
    
    func setupNotifications(){
    
        setupItemsDownloadNotifications()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: mySelectedItemNotificationKey), object: nil, queue: nil, using: catchNotification)
    }
    
    func setupItemsDownloadNotifications(){
        
        offersDownloaded = false
        requestsDownloaded = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationsPosted(notification:)), name: NSNotification.Name(rawValue: myOffersDownloadedNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationsPosted(notification:)), name: NSNotification.Name(rawValue: myRequestsDownloadedNotificationKey), object: nil)
    }
    
    func setNotificationsFromDelegator(category: ItemCategory?) {
        
        currentCategory = category
        setupItemsDownloadNotifications()
    }
    
    

    //receives info from mapViewDelegate about which itemAnnotation was clicked on
    func catchNotification(notification:Notification) -> Void {
        guard let name = notification.userInfo!["name"] as? Item else { return }
        self.showItemDetail(item: name)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.homeTableView.reloadData()
    }

    
    @objc func notificationsPosted(notification: NSNotification){
    
        if(notification.name == NSNotification.Name(rawValue: myOffersDownloadedNotificationKey)){
            offersDownloaded = true
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: myOffersDownloadedNotificationKey), object: nil)
            
        }
        
        if(notification.name == NSNotification.Name(rawValue: myRequestsDownloadedNotificationKey)){
            requestsDownloaded = true
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: myRequestsDownloadedNotificationKey), object: nil)
            
        }
        
        if(offersDownloaded && requestsDownloaded){
            
            offersDownloaded = false
            requestsDownloaded = false
            
            addAnnotationsWhenFinishedDownloadingData()
            
        }
    }
    
    
    @objc func addAnnotationsWhenFinishedDownloadingData(){
        removeAndAddAnnotations()
        sortTableView()
        BusyActivityView.hide()
        
    }
    
    func removeAndAddAnnotations(){
        self.homeMapView.removeAnnotations(homeMapView.annotations)
        
        if (searchApplied == true){
            if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
                self.homeMapView.addAnnotations(filteredRequestedItems)
            }
            else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
                self.homeMapView.addAnnotations(filteredOfferedItems)
            }
        }
        else {
        
            if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
                self.homeMapView.addAnnotations(AppData.sharedInstance.onlineRequestedItems)
            }
            else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
                self.homeMapView.addAnnotations(AppData.sharedInstance.onlineOfferedItems)
            }
        }
    }
    
    
    @IBAction func filterTapped(_ sender: UIBarButtonItem) {
        
        let filterViewController = FilterTableViewController()
        filterViewController.notificationDelegate = self
        self.navigationController?.pushViewController(filterViewController, animated: true)
       
        filterViewController.view.translatesAutoresizingMaskIntoConstraints = false
  
        filterViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        
    }
    
    //wantedAvailable segmenetd control
    @IBAction func changedWantedAvailableSegmnent(_ sender: UISegmentedControl) {
        
        lastItemSelected = nil
        
        if(sender.selectedSegmentIndex == 0){
            offerRequestBool = false
            self.homeMapView.removeAnnotations(AppData.sharedInstance.onlineOfferedItems)
            self.homeMapView.addAnnotations(AppData.sharedInstance.onlineRequestedItems)
            homeTableView.reloadData()
        }
        else if (sender.selectedSegmentIndex == 1){
            offerRequestBool = true
            self.homeMapView.removeAnnotations(AppData.sharedInstance.onlineRequestedItems)
            self.homeMapView.addAnnotations(AppData.sharedInstance.onlineOfferedItems)
            homeTableView.reloadData()
        }
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
            self.view.bringSubview(toFront: searchBar)
        }
        else if sender.selectedSegmentIndex == 1 {
            
            if (lastItemSelected != nil){
                highlightLastCell(itemIndexPath: currentItemIndexPath, type: self.wantedAvailableSegmentedControl.selectedSegmentIndex)
            }
            
            self.view.bringSubview(toFront: homeTableView)
            homeTableView.reloadData()
        }
    }
    
    
    @objc func refreshTableData(sender: AnyObject) {
        
        if((self.homeTableView.refreshControl) != nil){
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
            let title = String("Last update: \(dateFormatter.string(from: Date()))")
            let attributesDict = [NSAttributedStringKey.foregroundColor: UIColor.white]
            let attributedTitle = NSAttributedString(string: title, attributes: attributesDict)
            self.homeTableView.refreshControl?.attributedTitle = attributedTitle
        }
        
        setupItemsDownloadNotifications()
        
        ReadFirebaseData.readOffers(category: currentCategory)
        ReadFirebaseData.readRequests(category: currentCategory)
    
        self.homeTableView.refreshControl?.endRefreshing()
    }

    //segues
    @objc func postItem() {
        
        if(guestUser == true){
        
        let postAsGuestAlert = UIAlertController(title: "Sorry", message: "You need an account to make a post", preferredStyle: .alert)
        let createAccountAction = UIAlertAction(title: "Log in", style: .default, handler: { (alert: UIAlertAction!) in
            self.goToLoginVC()
            loggedInBool = false
        })
        let cancelAction = UIAlertAction(title: "Just browse", style: .cancel, handler: nil)
        
        postAsGuestAlert.addAction(createAccountAction)
        postAsGuestAlert.addAction(cancelAction)
        
        self.present(postAsGuestAlert, animated: true, completion: nil)
        }
        
        else {
            self.performSegue(withIdentifier: "postSegue", sender: self)
        }
    }
    
    @objc func allowProfileAccess(){
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "myUserDownloadNotificationKey"), object: nil)
    
        profileButton.isEnabled = true
    }
    
    @IBAction func toProfile(_ sender: Any) {
        
        if(guestUser == true){
            
            let postAsGuestAlert = UIAlertController(title: "Login/Signup?", message: nil, preferredStyle: .alert)
            let createAccountAction = UIAlertAction(title: "Yes", style: .default, handler: { (alert: UIAlertAction!) in
                self.goToLoginVC()
                loggedInBool = false
            })
            let cancelAction = UIAlertAction(title: "No, Just browse", style: .cancel, handler: nil)
            
            postAsGuestAlert.addAction(createAccountAction)
            postAsGuestAlert.addAction(cancelAction)
            
            self.present(postAsGuestAlert, animated: true, completion: nil)
        }
            
        else {
    
            performSegue(withIdentifier: "toProfileSegue", sender: self)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfileSegue"){
            let profileNavC = segue.destination as! UINavigationController
            
            let profileVC = profileNavC.viewControllers[0] as! ProfileViewController
            profileVC.logoutDelegate = self
            
            
        }
    }
    
    @objc func leaderboardButtonAction() {
        performSegue(withIdentifier: "leaderboardSegue", sender: self)
    }
    

    //tableView methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var itemToShow: Item
        
        switch(wantedAvailableSegmentedControl.selectedSegmentIndex){
        
            case 0:  itemToShow = AppData.sharedInstance.onlineRequestedItems[indexPath.row]
            case 1:  itemToShow = AppData.sharedInstance.onlineOfferedItems[indexPath.row]
            default:
                return
   
        }
        
        if (searchApplied == true){
            
            switch(wantedAvailableSegmentedControl.selectedSegmentIndex){
                
            case 0:  itemToShow = filteredRequestedItems[indexPath.row]
            case 1:  itemToShow = filteredOfferedItems[indexPath.row]
            default:
                return
                
            }
        }
        
        
        currentItemIndexPath = indexPath
        lastItemSelected = itemToShow
        
        mapListSegmentedControl.selectedSegmentIndex = 0
        mapListSegmentedControl.sendActions(for: UIControlEvents.valueChanged)
       
        homeMapView.selectAnnotation(itemToShow, animated: true)
        
        let span = MKCoordinateSpanMake(0.007, 0.007)
        
        homeMapView.setRegion(MKCoordinateRegionMake(itemToShow.coordinate, span) , animated: true)
     
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
            if(searchApplied == true) {
                return filteredRequestedItems.count
            }
            else {
                return AppData.sharedInstance.onlineRequestedItems.count
            }
        }
        else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
            if(searchApplied == true) {
                return filteredOfferedItems.count
            }
            else {
                return AppData.sharedInstance.onlineOfferedItems.count
            }
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(UINib(nibName: "ItemHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "itemHomeTableViewCellID")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemHomeTableViewCellID") as! ItemHomeTableViewCell
        let storageRef = Storage.storage().reference()
        var sourceArray:[Item]!
       
        if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
       
            if(searchApplied == true){
                sourceArray = filteredRequestedItems
            
            }
            else {
                sourceArray = AppData.sharedInstance.onlineRequestedItems
            }
            
            let destinationLocation: CLLocation = CLLocation(latitude: sourceArray[indexPath.row].location.latitude, longitude: sourceArray[indexPath.row].location.longitude)
            
            let distance = (destinationLocation.distance(from: getLocation())/1000)
            
            cell.itemTitleLabel.text = sourceArray[indexPath.row].name
            cell.itemQualityLabel.text = sourceArray[indexPath.row].quality.rawValue
         
            if (distance > 100){
              cell.itemDistanceLabel.text = ">100 kms"
            }
            else {
                cell.itemDistanceLabel.text = String(format: "%.1f", distance) + " kms"
            }
            
            cell.itemImageView.sd_setImage(with: storageRef.child(sourceArray[indexPath.row].photos[0]), placeholderImage: UIImage.init(named: "placeholder"))
        }
        else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
            
            if(searchApplied == true){
                sourceArray = filteredOfferedItems
            }
            else {
                sourceArray = AppData.sharedInstance.onlineOfferedItems
            }
            
            let destinationLocation: CLLocation = CLLocation(latitude: sourceArray[indexPath.row].location.latitude, longitude: sourceArray[indexPath.row].location.longitude)
            
            let distance = (destinationLocation.distance(from: getLocation())/1000)
            
            cell.itemTitleLabel.text = sourceArray[indexPath.row].name
            cell.itemQualityLabel.text = sourceArray[indexPath.row].quality.rawValue
            
            if (distance > 100){
                cell.itemDistanceLabel.text = ">100 kms"
            }
            else {
                cell.itemDistanceLabel.text = String(format: "%.1f", distance) + " kms"
            }
            cell.itemImageView.sd_setImage(with: storageRef.child(sourceArray[indexPath.row].photos[0]), placeholderImage: UIImage.init(named: "placeholder"))
        }
 
        return cell
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
        
        if (wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
            detailViewController.kindOfItem = "Request"
        }
        else{
            detailViewController.kindOfItem = "Offer"
        }
        
        addChildViewController(detailViewController)
        detailViewController.view.translatesAutoresizingMaskIntoConstraints = false
        itemDetailContainerView.addSubview(detailViewController.view)
        
       
        detailViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height+50)
        
        NSLayoutConstraint.activate([
            detailViewController.view.leadingAnchor.constraint(equalTo: itemDetailContainerView.leadingAnchor),
            detailViewController.view.trailingAnchor.constraint(equalTo: itemDetailContainerView.trailingAnchor),
            detailViewController.view.topAnchor.constraint(equalTo: itemDetailContainerView.topAnchor),
            detailViewController.view.bottomAnchor.constraint(equalTo: itemDetailContainerView.bottomAnchor)
            ])
        
        detailViewController.didMove(toParentViewController: self)
    }
    
    

    
    //0 for requests, 1 for offers
    func highlightLastCell(itemIndexPath: IndexPath, type: Int){
    
//        homeTableView.cellForRow(at: currentItemIndexPath)?.layer.backgroundColor = UIProperties.sharedUIProperties.purpleColour.cgColor
//
//        UIView.animate(withDuration: 1, animations: {
//
//                        self.homeTableView.cellForRow(at: self.currentItemIndexPath)?.layer.backgroundColor = UIProperties.sharedUIProperties.whiteColour.cgColor
//
//        }, completion: {(finished: Bool) in
//
//        })
//
//        self.homeTableView.scrollToRow(at: self.currentItemIndexPath, at: UITableViewScrollPosition.top, animated: true)

    }
    
    
    
    //searchBar delegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        searchApplied = true
        
        if (searchBar.text == ""){
            searchApplied = false
        }
        
        filteredOfferedItems = []
        filteredRequestedItems = []
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        searchApplied = true
        
        if (searchBar.text == ""){
            searchApplied = false
        }
        
        self.view.removeGestureRecognizer(tapGesture)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchApplied = false
        homeTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchApplied = true
        
        if (searchBar.text == ""){
            searchApplied = false
        }
        
        searchThroughData(searchText: searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchApplied = true
        
        filteredOfferedItems = []
        filteredRequestedItems = []
        
        
        if (searchBar.text == ""){
            searchApplied = false
        }
        
        searchThroughData(searchText: searchText)
        
    }
    
    func searchThroughData(searchText: String) {
    
        var containsTag: Bool = false
        
        for item in AppData.sharedInstance.onlineOfferedItems {
            
            if (item.name.lowercased().contains(searchText.lowercased())){
                filteredOfferedItems.append(item)
            }
            
            for tag in item.tags.tagsArray {
                if (tag.lowercased().contains(searchText.lowercased())){
                    containsTag = true
                }
                else { containsTag = false }
                
                
                if (containsTag == true) {
                    if !(filteredOfferedItems.contains(item)){
                        filteredOfferedItems.append(item)
                    }
                    
                    break
                }
            }
        }
        
        containsTag = false
        
        for item in AppData.sharedInstance.onlineRequestedItems {
            
            if (item.name.lowercased().contains(searchText.lowercased())){
                filteredRequestedItems.append(item)
            }
            
            for tag in item.tags.tagsArray {
                if (tag.lowercased().contains(searchText.lowercased())){
                    containsTag = true
                }
                else { containsTag = false }
                
                
                if (containsTag == true) {
                    if !(filteredRequestedItems.contains(item)){
                        filteredRequestedItems.append(item)
                    }
                    break
                }
            }
        }
        
        searchActive = true
        self.homeTableView.reloadData()
        removeAndAddAnnotations()
    }
}

