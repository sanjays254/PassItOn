//
//  PostMapViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-20.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import MapKit


class PostMapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {

    var searchController: UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var markerAnnotationView:MKMarkerAnnotationView!
    
    public var selectedLocationString: String!
    public var selectedLocationCoordinates: CLLocationCoordinate2D!
    
    @IBOutlet weak var postMapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchButton = UIBarButtonItem(image:UIImage(named:"search"), style: .plain, target: self, action: #selector(searchButtonClicked))
        
        self.navigationItem.rightBarButtonItem = searchButton
        
        self.postMapView.delegate = MapViewDelegate.theMapViewDelegate
        MapViewDelegate.theMapViewDelegate.theMapView = self.postMapView
        MapViewDelegate.theMapViewDelegate.setMapRegion()
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func searchButtonClicked () {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.postMapView.annotations.count != 0{
            annotation = self.postMapView.annotations[0]
            self.postMapView.removeAnnotation(annotation)
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
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            

            self.markerAnnotationView = MKMarkerAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
  
            
            self.postMapView.centerCoordinate = self.pointAnnotation.coordinate
            self.postMapView.addAnnotation(self.markerAnnotationView.annotation!)
            
        }
    }
    
    
    @IBAction func saveLocationButon(_ sender: UIButton) {
        
        let myVCindex = self.navigationController?.viewControllers.index(of: self)
        
        self.navigationController?.popViewController(animated: true
        )
        
        let previousVC = self.navigationController?.viewControllers[myVCindex!-1] as! PostViewController
        previousVC.selectedLocationString = self.pointAnnotation.title!
        
    }
    
}
