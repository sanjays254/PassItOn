//
//  LocationManager.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-16.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices


class LocationManager: CLLocationManager{
    
    var currentLocation: CLLocation!
    
    static let theLocationManager = LocationManager()

    func getLocation() -> CLLocation {
        LocationManager.theLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        LocationManager.theLocationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("No access")
                           currentLocation = CLLocation.init(latitude: CLLocationDegrees(49.261725), longitude: CLLocationDegrees(-123.244621))
                
            case .authorizedAlways, .authorizedWhenInUse:
                
                currentLocation = self.location
                LocationManager.theLocationManager.startUpdatingLocation()
                print("Access")
            }
            
            if (self.location == nil){
                currentLocation = CLLocation.init(latitude: CLLocationDegrees(49.261725), longitude: CLLocationDegrees(-123.244621))
            }
        } else {
           currentLocation = CLLocation.init(latitude: CLLocationDegrees(49.246292), longitude: CLLocationDegrees(-123.116226))
            print("Location services are not enabled")
        }
        
        return currentLocation
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            currentLocation = self.location
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            // If always authorized
            currentLocation = self.location
            manager.startUpdatingLocation()
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            break

        }
    }
    
}
