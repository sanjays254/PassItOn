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
    var currentLocation: CLLocation? = LocationManager.theLocationManager.getLocation()
    
    let myNotificationKey = "mySelectedItemNotificationKey"
    
    static let theMapViewDelegate = MapViewDelegate()
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        //if we are at default Apple coordinate (0,0), then update region
        let lat: Float = Float(theMapView.region.center.latitude)
        let long: Float = Float(theMapView.region.center.longitude)
        
        if (lat == 0 && long == 0) {
            
            let span = MKCoordinateSpanMake(0.02, 0.02)
            theMapView.region = MKCoordinateRegionMake((self.currentLocation?.coordinate)!, span)
        }
        
        currentLocation = LocationManager.theLocationManager.getLocation()
    }
    
    @objc func setMapRegion(){
        let span = MKCoordinateSpanMake(0.025, 0.025)
        
        theMapView.region = MKCoordinateRegionMake((self.currentLocation?.coordinate)!, span)
        theMapView.showsUserLocation = true
        theMapView.showsPointsOfInterest = false
    }
    
    @objc func setInitialMapRegion(){
        let span = MKCoordinateSpanMake(0.025, 0.025)
        
        theMapView.region = MKCoordinateRegionMake((self.currentLocation?.coordinate)!, span)
        theMapView.showsUserLocation = true
        theMapView.showsPointsOfInterest = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let cluster = annotation as? MKClusterAnnotation {
        
            let markerAnnotationView = MKMarkerAnnotationView()
            markerAnnotationView.glyphText = String(cluster.memberAnnotations.count)
            markerAnnotationView.markerTintColor = UIProperties.sharedUIProperties.purpleColour
            markerAnnotationView.glyphTintColor = UIProperties.sharedUIProperties.lightGreenColour
            markerAnnotationView.titleVisibility = .hidden
            markerAnnotationView.subtitleVisibility = .hidden
            markerAnnotationView.canShowCallout = false
            
            return markerAnnotationView
         
        }
        
        if (annotation is MKUserLocation){
            return nil
        }
        else if (annotation is Item){
            
            return self.getMarkerFor(annotation: annotation, mapView: mapView)
        }
        else if (annotation is MKPointAnnotation){
            return self.getPostMarkerFor(annotation: annotation, mapView: mapView)
        }
            
        else {
            return nil
        }
    }

    func getMarkerFor(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        let item = annotation as! Item
        
        let newItemMarkerView = mapView.dequeueReusableAnnotationView(withIdentifier: "itemMarkerView", for: annotation) as! MKMarkerAnnotationView
        
        newItemMarkerView.clusteringIdentifier = "clusteringIdentifier"
        
        setMarkerPropertiesFor(newMarkerView: newItemMarkerView, item: item)

        return newItemMarkerView
    }
    
    
    func setMarkerPropertiesFor(newMarkerView: MKMarkerAnnotationView, item: Item){
        
        newMarkerView.markerTintColor = UIProperties.sharedUIProperties.purpleColour
        newMarkerView.glyphTintColor = UIProperties.sharedUIProperties.lightGreenColour
        
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
        }
    }
    
    
    func getPostMarkerFor(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
       
        let postLocationMarkerView = mapView.dequeueReusableAnnotationView(withIdentifier: "postLocationMarkerView", for: annotation) as! MKMarkerAnnotationView
        
        postLocationMarkerView.glyphTintColor = UIProperties.sharedUIProperties.purpleColour
        
        return postLocationMarkerView
    }
    
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        
        return MKClusterAnnotation(memberAnnotations: memberAnnotations)
        
    }
    

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       // mapView.selectAnnotation(view.annotation!, animated: true)
       
        if (view.annotation is MKUserLocation){
           return
        }
        else if (view.annotation is MKClusterAnnotation){
            
            if let cluster = view.annotation as? MKClusterAnnotation {
                let span = getSpanOfFurthestAnnotations(annotations: cluster.memberAnnotations)
                
                //if theyre in the same exact place
                if (span.latitudeDelta == 0 && span.longitudeDelta == 0){
                    
                    theMapView.setRegion(MKCoordinateRegionMake((view.annotation?.coordinate)!, span) , animated: true)
                    
                    var index = 0
                    for annotation in cluster.memberAnnotations{
                       
                        if let item = annotation as? Item {
                           item.coordinate.longitude = item.coordinate.longitude + (Double(index) * 0.0001)
                        }
                        theMapView.removeAnnotation(annotation)
                         index += 1
                    }
                    
                    theMapView.addAnnotations(cluster.memberAnnotations)
                }
                else {
                theMapView.setRegion(MKCoordinateRegionMake((view.annotation?.coordinate)!, span) , animated: true)
                }
            }
        }
        else {
            
            guard let myItem = view.annotation as? Item
                
                else {
                    return
            }
            
            var span: MKCoordinateSpan
            
            //keep zoom the same unless were zoomed out
            if (theMapView.region.span.latitudeDelta > 0.02 || theMapView.region.span.longitudeDelta > 0.02 ) {
                span = MKCoordinateSpanMake(0.02, 0.02)
            }
            else {
                span = theMapView.region.span
            }
            
            theMapView.setRegion(MKCoordinateRegionMake((view.annotation?.coordinate)!, span) , animated: true)
            
    
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: myNotificationKey), object: nil, userInfo: ["name" : myItem])
        }
    }
    
    func displaySelectedAnnotation(annotation: MKPointAnnotation){
        theMapView.removeAnnotations(theMapView.annotations)
        theMapView.addAnnotation(annotation)
    }
    
    func getSpanOfFurthestAnnotations(annotations: [MKAnnotation]) -> MKCoordinateSpan{
        
        var furthestDistance: CLLocationDistance = 0.0
        var span: MKCoordinateSpan = MKCoordinateSpanMake(0, 0)
        
        for firstAnnotation in annotations {
            for secondAnnotation in annotations {
                
                let firstAnnotationCoordinate = firstAnnotation.coordinate
                let secondAnnotationCoordinate = secondAnnotation.coordinate
                
                let firstAnnotationLocation = CLLocation(latitude: firstAnnotationCoordinate.latitude, longitude: firstAnnotationCoordinate.longitude)
                let secondAnnotationLocation = CLLocation(latitude: secondAnnotationCoordinate.latitude, longitude: secondAnnotationCoordinate.longitude)
            
                
                let distance = firstAnnotationLocation.distance(from: secondAnnotationLocation)
                
                if distance > furthestDistance {
                    furthestDistance = distance
                    
                    span =  MKCoordinateSpanMake(CLLocationDegrees(abs(firstAnnotationCoordinate.latitude - secondAnnotationCoordinate.latitude)*1.4), CLLocationDegrees(abs(firstAnnotationCoordinate.longitude - secondAnnotationCoordinate.longitude)*1.4))
                    
                }
                
            }
        }
       
        
        return span
        
    }

}
