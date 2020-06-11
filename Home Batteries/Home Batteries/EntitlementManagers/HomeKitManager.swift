//
//  HomeKitManager.swift
//  Home Batteries
//
//  Created by Max Obermeier on 11.06.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import Combine

class HomeKitManager: NSObject, ObservableObject, HMHomeManagerDelegate {
    
    @Published var value: HMHomeManager
    
    override init() {
        self.value = HMHomeManager()
        super.init()
        
        self.value.delegate = self
    }
    
    deinit {
        self.value.delegate = nil
    }
    
    func homeManager(_ manager: HMHomeManager, didUpdate status: HMHomeManagerAuthorizationStatus) {
        guard manager == self.value else { return }
        self.value = manager
    }
    
}


