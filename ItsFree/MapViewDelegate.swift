//
//  MapViewDelegate.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-18.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import MapKit



class MapViewDelegate: NSObject, MKMapViewDelegate {
    
    var theMapView: MKMapView!
    var currentLocation: CLLocation = LocationManager.theLocationManager.getLocation()
    
    static let theMapViewDelegate = MapViewDelegate()
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        //if we are at default Apple coordinate (0,0), then update region
        let lat: Float = Float(theMapView.region.center.latitude)
        let long: Float = Float(theMapView.region.center.longitude)
        
        if (lat == 0 && long == 0) {
            
            let span = MKCoordinateSpanMake(0.007, 0.007)
            theMapView.region = MKCoordinateRegionMake(self.currentLocation.coordinate, span)
        }
    }
    
    func setMapRegion(){
        
        let span = MKCoordinateSpanMake(0.007, 0.007)
        
        theMapView.region = MKCoordinateRegionMake(self.currentLocation.coordinate, span)
        theMapView.showsUserLocation = true
        theMapView.showsPointsOfInterest = false

    }

}
