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
        
        if(self.location != nil){
            currentLocation = self.location
        }
        else {
            currentLocation = CLLocation.init(latitude: CLLocationDegrees(49.246292), longitude: CLLocationDegrees(-123.116226))
        }
        return currentLocation
        
        
    }
    

    
}
