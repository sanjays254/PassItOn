//
//  PostMapViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-20.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import MapKit


class PostMapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, MKLocalSearchCompleterDelegate, UITableViewDelegate,UITableViewDataSource {
    

    var previousVC: PostViewController!
    
    var searchController: UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
   // var pinAnnotationView:MKPinAnnotationView!
    var markerAnnotationView:MKMarkerAnnotationView!
    
    //auto-complete search variables
    var searchCompleter: MKLocalSearchCompleter!
    var searchResults : [MKLocalSearchCompletion]!
    var searchResultsTableView: UITableView!
    
    @IBOutlet weak var postMapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let myVCindex = self.navigationController?.viewControllers.index(of: self)
        previousVC = self.navigationController?.viewControllers[myVCindex!-1] as! PostViewController
        
        let searchButton = UIBarButtonItem(image:UIImage(named:"search"), style: .plain, target: self, action: #selector(searchButtonClicked))
        
        self.navigationItem.rightBarButtonItem = searchButton
        
        self.postMapView.delegate = MapViewDelegate.theMapViewDelegate
        MapViewDelegate.theMapViewDelegate.theMapView = self.postMapView
        MapViewDelegate.theMapViewDelegate.setMapRegion()
        
        
        //searchCompleter delegate stuff
        self.searchCompleter = MKLocalSearchCompleter()
        self.searchCompleter.delegate = self
        self.searchCompleter.filterType = MKSearchCompletionFilterType.locationsAndQueries
        
       
        print(self.searchCompleter.isSearching)
        self.searchResults = [MKLocalSearchCompletion]()
        
    }

    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
         self.searchCompleter.region = self.postMapView.region
    }

 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        self.searchCompleter.queryFragment = self.searchController.searchBar.text!
        self.view.addSubview(searchResultsTableView)
        self.view.bringSubview(toFront: searchResultsTableView)
        self.searchResultsTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchCompleter.queryFragment = self.searchController.searchBar.text!
        self.searchResultsTableView.reloadData()
    }
    
    @objc func searchButtonClicked () {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.text = previousVC.selectedLocationString
        present(searchController, animated: true, completion: nil)
        
        
    
        //search completer tableView
        searchResultsTableView = UITableView(frame: CGRect(x: 20, y:20, width: 250, height: 500), style: UITableViewStyle.plain)
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        
        //searchCompleter.queryFragment = "Nemesis"
        searchResultsTableView.reloadData()
    }
    
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //handleError
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        

        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if (self.pointAnnotation != nil) {
            //annotation = self.postMapView.annotations[0]
            self.postMapView.removeAnnotation(pointAnnotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            
           // self.pointAnnotation = localSearchResponse?.mapItems[0].placemark.thoroughfare
            
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            

            self.markerAnnotationView = MKMarkerAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
     
            
            self.postMapView.centerCoordinate = self.pointAnnotation.coordinate
            self.postMapView.addAnnotation(self.markerAnnotationView.annotation!)
            
        }
    }
    
    
    @IBAction func saveLocationButon(_ sender: UIButton) {
        
       
        
        self.navigationController?.popViewController(animated: true
        )
        
        
        previousVC.selectedLocationString = self.pointAnnotation.title ?? ""
        previousVC.selectedLocationCoordinates = self.pointAnnotation.coordinate
        
    }
    
}
