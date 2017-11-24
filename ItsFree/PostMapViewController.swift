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
    
   
    
    @IBOutlet weak var postMapView: MKMapView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true

        let myVCindex = self.navigationController?.viewControllers.index(of: self)
        previousVC = self.navigationController?.viewControllers[myVCindex!-1] as! PostViewController
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(searchButtonClicked))
        
        //mapView Delegate stuff
        self.postMapView.delegate = MapViewDelegate.theMapViewDelegate
        MapViewDelegate.theMapViewDelegate.theMapView = self.postMapView
        MapViewDelegate.theMapViewDelegate.setMapRegion()
        
        //searchCompleter delegate stuff
        self.searchCompleter = MKLocalSearchCompleter()
        self.searchCompleter.delegate = self
        self.searchCompleter.region = self.postMapView.region
        self.searchCompleter.filterType = MKSearchCompletionFilterType.locationsAndQueries
    
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
        
//        searchController.hidesNavigationBarDuringPresentation = true
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
            
            self.postMapView.centerCoordinate = self.pointAnnotation.coordinate
            self.postMapView.addAnnotation(self.markerAnnotationView.annotation!)
        }
    }
    
    
    @IBAction func saveLocationButon(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        previousVC.selectedLocationString = self.pointAnnotation.title ?? ""
        previousVC.selectedLocationCoordinates = self.pointAnnotation.coordinate
        
    }
}

