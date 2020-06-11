//
//  LocationManager.swift
//  Home Batteries
//
//  Created by Max Obermeier on 11.06.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var value: CLLocationManager
    
    override init() {
        self.value = CLLocationManager()
        super.init()
        
        self.value.delegate = self
    }
    
    deinit {
        self.value.delegate = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard manager == self.value else { return }
        self.value = manager
    }
    
}

