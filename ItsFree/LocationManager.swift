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


class LocationManager: CLLocationManager {
    
    var currentLocation: CLLocation!
    
    static let theLocationManager = LocationManager()
    
    func getLocation() -> CLLocation {
        

        
        self.desiredAccuracy = kCLLocationAccuracyBest
        self.requestWhenInUseAuthorization()
        self.startUpdatingLocation()
        
    
        //locationManager = CLLocationManager()
        //self.locationManager.delegate = self
        currentLocation = self.location
        return currentLocation
        
        
    }
    

    
}
