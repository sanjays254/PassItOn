//
//  ViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-16.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//


import UIKit
import MapKit
import FirebaseStorage
import MessageUI

public var offerRequestBool: Bool!


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, UINavigationControllerDelegate, UISearchBarDelegate, NotificationDelegate, LoggedOutDelegate,ItemActionDelegate, HomeMarkerSelectionDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {

    
    var storageRef: StorageReference!
    
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
    
    var rowSelected: Bool!
    var indexPathSelected: IndexPath?
    var indexPathPreviouslySelected: IndexPath?
    
    var currentCategory: ItemCategory?
    
    var topVC: UIViewController?
  
    var searchActive : Bool = false
    var searchApplied : Bool = false
    var filteredOfferedItems:[Item]!
    var filteredRequestedItems:[Item]!
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storageRef = Storage.storage().reference()
        
        wantedAvailableSegmentedControl.selectedSegmentIndex = 1
        offerRequestBool = true
        
        //delegating the tableView
        self.homeTableView.delegate = self
        self.homeTableView.dataSource = self
        self.homeTableView.estimatedRowHeight = 140
  
        rowSelected = false
        
        
        
        self.homeTableView.register(UINib(nibName: "ItemHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "itemHomeTableViewCellID")
        
        
        self.homeTableView.register(UINib(nibName: "ItemDetailHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "itemHomeDetailTableViewCellID")
        
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
    func getLocation() -> CLLocation {
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
        indexPathSelected = nil
        indexPathPreviouslySelected = nil
        
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
        
        //BusyActivityView.show(inpVc: self)
        
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
    
    func selectMarker(item: Item) {
        
        
        mapListSegmentedControl.selectedSegmentIndex = 0
        mapListSegmentedControl.sendActions(for: UIControlEvents.valueChanged)
        
        homeMapView.selectAnnotation(item, animated: true)
        
        let span = MKCoordinateSpanMake(0.007, 0.007)
        
        homeMapView.setRegion(MKCoordinateRegionMake(item.coordinate, span) , animated: true)
        

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
        detailViewController.itemActionDelegate = self
        
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
    
    
    func sendPosterMessage(inpVC: UIViewController, currentItem: Item, destinationUser: User) {
        
        if(AppData.sharedInstance.currentUser!.UID == destinationUser.UID){
            //show alert
            let usersOwnItemAlert = UIAlertController(title: "Oops", message: "This item was posted by you", preferredStyle: UIAlertControllerStyle.alert)
            let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
            usersOwnItemAlert.addAction(okayAction)
            inpVC.present(usersOwnItemAlert, animated: true, completion: nil)
            
        }
        else {
            
            if (destinationUser.phoneNumber != 0){
                
                let textOrEmailAlert = UIAlertController(title: "\(destinationUser.name) has shared a cell number", message: "How would you like to message \(destinationUser.name)?", preferredStyle: .actionSheet)
                
                let emailAction = UIAlertAction(title: "Email", style: .default, handler: {_ in
                    self.emailChosen(inpVC: inpVC, item: currentItem, destinationUser: destinationUser)})
                
                let textAction = UIAlertAction(title: "Text", style: .default, handler: {_ in
                    self.textChosen(inpVC: inpVC, item: currentItem, destinationUser: destinationUser)})
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                textOrEmailAlert.addAction(emailAction)
                textOrEmailAlert.addAction(textAction)
                textOrEmailAlert.addAction(cancelAction)
                
                inpVC.present(textOrEmailAlert, animated: true, completion: nil)
            }
            else {
                emailChosen(inpVC: inpVC, item: currentItem, destinationUser: destinationUser)
            }
        }
        
        
    }
    
    
    
    func fullscreenImage(imagePath : String, inpVC: UIViewController) {
        
        if (imagePath == ""){
            let noImageAlert = UIAlertController(title: "Sorry", message: "This item doesn't have an image", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            noImageAlert.addAction(okayAction)
            
            inpVC.present(noImageAlert, animated: true, completion: nil)
        }
            
        else {
            
            let newImageView = UIImageView()
            newImageView.sd_setImage(with: storageRef.child(imagePath), placeholderImage: UIImage.init(named: "placeholder"))
            
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: inpVC, action: #selector(dismissFullscreenImage(sender:)))
            newImageView.addGestureRecognizer(tap)
            inpVC.view.addSubview(newImageView)
            inpVC.navigationController?.isNavigationBarHidden = true
            inpVC.tabBarController?.tabBar.isHidden = true
            
        
            
        }
    }
    
    
    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
    
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        sender.view?.removeFromSuperview()
        
    }
    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
}

