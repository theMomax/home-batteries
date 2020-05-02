//
//  Home.swift
//  Home Batteries
//
//  Created by Max Obermeier on 01.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import Combine


/// - Tag: Home
class Home: NSObject, ObservableObject, HMHomeDelegate {
    
    @Published var home: HMHome
    
    init(_ home: HMHome) {
        self.home = home
        
        super.init()
        
        self.home.delegate = self
    }
    
    func homeDidUpdateName(_ home: HMHome) {
        guard home == self.home else { return }
        print("home name updated")
        self.home = home
    }
  
    func home(_ home: HMHome, didAdd room: HMRoom) {
        guard home == self.home else { return }
        print("room was added to home")
        self.home = home
    }
    
    
    func home(_ home: HMHome, didRemove room: HMRoom) {
        guard home == self.home else { return }
        print("room was removed from home")
        self.home = home
    }
    
    func home(_ home: HMHome, didUpdate room: HMRoom, for accessory: HMAccessory) {
        guard home == self.home else { return }
        print("accessory room did change")
        self.home = home
    }
}
