//
//  PostMapViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-20.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import MapKit


class PostMapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, MKLocalSearchCompleterDelegate {
    
    @IBOutlet weak var myLocationButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    var previousVC: PostViewController!
    
    var searchController: UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
   
    var markerAnnotationView:MKMarkerAnnotationView!
    var searchCompleter: MKLocalSearchCompleter!
    
    let searchResultsTableViewController = SearchResultsTableViewController()
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var selectedAnnotation: MKPointAnnotation!
    
    @IBOutlet weak var postMapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        
        selectedAnnotation = MKPointAnnotation()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedALocation(sender:)))
        postMapView.addGestureRecognizer(tapGestureRecognizer)

        let myVCindex = self.navigationController?.viewControllers.index(of: self)
        previousVC = self.navigationController?.viewControllers[myVCindex!-1] as! PostViewController
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(searchButtonClicked))
        self.navigationItem.title = "Select Location"
        
        //mapView Delegate stuff
        self.postMapView.delegate = MapViewDelegate.theMapViewDelegate
        MapViewDelegate.theMapViewDelegate.theMapView = self.postMapView
        MapViewDelegate.theMapViewDelegate.setMapRegion()
        
        //searchCompleter delegate stuff
        self.searchCompleter = MKLocalSearchCompleter()
        self.searchCompleter.delegate = self
        self.searchCompleter.region = self.postMapView.region
        self.searchCompleter.filterType = MKSearchCompletionFilterType.locationsAndQueries
        
        self.saveButton.tintColor = UIProperties.sharedUIProperties.lightGreenColour
        self.saveButton.layer.backgroundColor =  UIProperties.sharedUIProperties.blackColour.cgColor
        self.saveButton.layer.cornerRadius = 8
        self.saveButton.layer.masksToBounds = false
        self.saveButton.layer.shadowOffset = CGSize.init(width: 0, height: 2.0)
        self.saveButton.layer.shadowColor = (UIColor.black).cgColor
        self.saveButton.layer.shadowOpacity = 0.5
        self.saveButton.layer.shadowRadius = 1.0
        
        self.myLocationButton.tintColor = UIProperties.sharedUIProperties.lightGreenColour
        self.myLocationButton.layer.backgroundColor = UIProperties.sharedUIProperties.blackColour.cgColor
        self.myLocationButton.layer.cornerRadius = 8
        self.myLocationButton.layer.masksToBounds = false
        self.myLocationButton.layer.shadowOffset = CGSize.init(width: 0, height: 2.0)
        self.myLocationButton.layer.shadowColor = (UIColor.black).cgColor
        self.myLocationButton.layer.shadowOpacity = 0.5
        self.myLocationButton.layer.shadowRadius = 1.0
        
        
    self.postMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "postLocationMarkerView")
        
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
         self.searchCompleter.region = self.postMapView.region
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func searchButtonClicked () {

        searchController = UISearchController(searchResultsController: searchResultsTableViewController)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchCompleter.queryFragment = self.searchController.searchBar.text!
        searchResultsTableViewController.tableView.reloadData()
    }
    
    //search-completer delegate methods
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResultsTableViewController.searchResults = completer.results
        searchResultsTableViewController.tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //handleError
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        searchResultsTableViewController.placeToSearch = searchBar.text!
        locationPlotter()
    }
    
    func locationPlotter(){
   
        //remove existing annotation
        if (self.pointAnnotation != nil) {
            self.postMapView.removeAnnotation(pointAnnotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchResultsTableViewController.placeToSearch
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.searchResultsTableViewController.placeToSearch
            
            // self.pointAnnotation = localSearchResponse?.mapItems[0].placemark.thoroughfare
            
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            self.markerAnnotationView = MKMarkerAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.markerAnnotationView.markerTintColor = UIProperties.sharedUIProperties.purpleColour
            
            
            self.postMapView.centerCoordinate = self.pointAnnotation.coordinate
            self.postMapView.addAnnotation(self.markerAnnotationView.annotation!)
        }
    }
    
    
    @IBAction func saveLocationButon(_ sender: UIButton) {
        
        if (self.pointAnnotation != nil){
            self.navigationController?.popViewController(animated: true)
            previousVC.selectedLocationString = self.pointAnnotation.title ?? ""
            previousVC.selectedLocationCoordinates = self.pointAnnotation.coordinate
        }
        else {
            
            let noLocationAlert = UIAlertController(title: "Can't Save!", message: "Select a location before saving", preferredStyle: UIAlertControllerStyle.alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
            
            noLocationAlert.addAction(okayAction)
            present(noLocationAlert, animated: true, completion: nil)
        }
        

        
    }
    
    
    @objc func tappedALocation(sender: UITapGestureRecognizer) {
        
        let touchLocation = sender.location(in: postMapView)
        let locationCoordinate = postMapView.convert(touchLocation, toCoordinateFrom: postMapView)
        
        if (self.pointAnnotation != nil) {
            self.postMapView.removeAnnotation(self.pointAnnotation)
        }
        
        pointAnnotation = MKPointAnnotation()
    
        pointAnnotation.coordinate = locationCoordinate
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude), completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks!.count > 0) {
                let pm = placemarks![0]
                
                if(pm.thoroughfare != nil && pm.subThoroughfare != nil){
                    // not all places have thoroughfare & subThoroughfare so validate those values
                    self.pointAnnotation.title = pm.thoroughfare! + ", " + pm.subThoroughfare!
                    self.pointAnnotation.subtitle = pm.subLocality
                    self.postMapView.addAnnotation(self.pointAnnotation)
                    print(pm)
                }
                else if(pm.subThoroughfare != nil) {
                    self.pointAnnotation.title = pm.thoroughfare!
                    self.pointAnnotation.subtitle = pm.subLocality
                    self.postMapView.addAnnotation(self.pointAnnotation)
                    print(pm)
                }
                    
                else {
                    self.pointAnnotation.title = "Unknown Place"
                    self.postMapView.addAnnotation(self.pointAnnotation)
                    print("Problem with the data received from geocoder")
                    
                }
            }
            else {
                self.pointAnnotation.title = "Unknown Place"
                self.postMapView.addAnnotation(self.pointAnnotation)
                print("Problem with the data received from geocoder")
            }
           // places.append(["name":annotation.title,"latitude":"\(locationCoordinate.latitude)","longitude":"\(locationCoordinate.longitude)"])
        })
        
    }
    
    
    @IBAction func useMyLocationButton(_ sender: UIButton) {
        
        
        CLGeocoder().reverseGeocodeLocation(LocationManager.theLocationManager.getLocation(), completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks!.count > 0) {
                let pm = placemarks![0]
                
                self.navigationController?.popViewController(animated: true)
                self.previousVC.selectedLocationString = pm.thoroughfare! + ", " + pm.subThoroughfare!
                self.previousVC.selectedLocationCoordinates = LocationManager.theLocationManager.getLocation().coordinate
                
                // not all places have thoroughfare & subThoroughfare so validate those values
            }
            else {
                self.pointAnnotation.title = "Unknown Place"
                self.postMapView.addAnnotation(self.pointAnnotation)
                print("Problem with the data received from geocoder")
            }
            // places.append(["name":annotation.title,"latitude":"\(locationCoordinate.latitude)","longitude":"\(locationCoordinate.longitude)"])
        })
    }
    
}

