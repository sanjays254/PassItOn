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
    
    let myNotificationKey = "theNotificationKey"
    
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
    
    @objc func setMapRegion(){
        
        let span = MKCoordinateSpanMake(0.007, 0.007)
        
        theMapView.region = MKCoordinateRegionMake(self.currentLocation.coordinate, span)
        theMapView.showsUserLocation = true
        theMapView.showsPointsOfInterest = false
        

    }
    
    func setMarkerPropertiesFor(newMarkerView: MKMarkerAnnotationView, item: Item){
        //newMarkerView.titleVisibility = MKFeatureVisibility.visible
        //newMarkerView.canShowCallout = true
        
        //newMarkerView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        newMarkerView.glyphText = item.itemCategory.rawValue
        
        
    }
    
    func getMarkerFor(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        let item = annotation as! Item
        
        let newItemMarkerView = mapView.dequeueReusableAnnotationView(withIdentifier: "itemMarkerView", for: annotation) as! MKMarkerAnnotationView
        
        setMarkerPropertiesFor(newMarkerView: newItemMarkerView, item: item)
        
        return newItemMarkerView
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation){
            return nil
        }
        else if (annotation is Item){
            
            return self.getMarkerFor(annotation: annotation, mapView: mapView)
        }
        else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       // mapView.selectAnnotation(view.annotation!, animated: true)
       
        if (view.annotation is MKUserLocation){
           //do nothing
        }
        
        else {
            let myItem = view.annotation as! Item
            NotificationCenter.default.post(name: Notification.Name(rawValue: myNotificationKey), object: nil, userInfo: ["name" : myItem])

        }
        

    }
    
    func displaySelectedAnnotation(annotation: MKPointAnnotation){
        theMapView.removeAnnotations(theMapView.annotations)
        theMapView.addAnnotation(annotation)
    }

}
