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

        
        
        switch(item.itemCategory){
        case .clothing : newMarkerView.glyphImage = #imageLiteral(resourceName: "clothing")
        case .books : newMarkerView.glyphImage = #imageLiteral(resourceName: "book")
        case .electronics : newMarkerView.glyphImage = #imageLiteral(resourceName: "electronics")
        case .furniture : newMarkerView.glyphImage = #imageLiteral(resourceName: "furniture")
        case .sportingGoods : newMarkerView.glyphImage = #imageLiteral(resourceName: "sports")
        case .artAndCollectables : newMarkerView.glyphImage = #imageLiteral(resourceName: "art")
        case .homeAppliances : newMarkerView.glyphImage = #imageLiteral(resourceName: "homeApplicance")
        case .toys :newMarkerView.glyphImage = #imageLiteral(resourceName: "toys")
        case .buildingToolsAndSupplies : newMarkerView.glyphImage = #imageLiteral(resourceName: "tools")
        case .jewelleryAndWatches : newMarkerView.glyphImage = #imageLiteral(resourceName: "jewellery")
        case .indoorDecor : newMarkerView.glyphImage = #imageLiteral(resourceName: "indoorDecor")
        case .outdoorDecor : newMarkerView.glyphImage = #imageLiteral(resourceName: "outdoorDecor")
        case .other : newMarkerView.glyphImage = #imageLiteral(resourceName: "random")
        default :newMarkerView.glyphImage = #imageLiteral(resourceName: "compass")
        }
    }
    
    func getMarkerFor(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        let item = annotation as! Item
        
        let newItemMarkerView = mapView.dequeueReusableAnnotationView(withIdentifier: "itemMarkerView", for: annotation) as! MKMarkerAnnotationView
        
        if let cluster = annotation as? MKClusterAnnotation {
            newItemMarkerView.glyphText = String(cluster.memberAnnotations.count)
            return newItemMarkerView
        }
        else {
        setMarkerPropertiesFor(newMarkerView: newItemMarkerView, item: item)
        }
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
           return
        }
        else {
            let span = MKCoordinateSpanMake(0.007, 0.007)
            theMapView.setRegion(MKCoordinateRegionMake((view.annotation?.coordinate)!, span) , animated: true)
            
            guard let myItem = view.annotation as? Item
                
                else {
                    return
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: myNotificationKey), object: nil, userInfo: ["name" : myItem])
        }
    }
    
    func displaySelectedAnnotation(annotation: MKPointAnnotation){
        theMapView.removeAnnotations(theMapView.annotations)
        theMapView.addAnnotation(annotation)
    }

}
