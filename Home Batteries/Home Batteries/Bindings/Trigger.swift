//
//  Trigger.swift
//  Home Batteries
//
//  Created by Max Obermeier on 20.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Combine
import HomeKit

/// - Tag: Trigger
class Trigger<T: HMTrigger>: NSObject, ObservableObject, HMHomeDelegate {
    
    let home: HMHome
    
    @Published var value: T
    
    init(_ trigger: T, in home: HMHome) {
        self.value = trigger
        self.home = home
        
        super.init()
        
        self.home.delegate = HomeStore.shared
        
        HomeStore.shared.addHomeDelegate(self)
    }
    
    deinit {
        HomeStore.shared.removeHomeDelegate(self)
    }
    
    func home(_ home: HMHome, didUpdateNameFor trigger: HMTrigger) {
        guard home == self.home && self.value == trigger else { return }
        self.value = trigger as! T
    }
    
    func home(_ home: HMHome, didUpdate trigger: HMTrigger) {
        guard home == self.home && self.value == trigger else { return }
        self.value = trigger as! T
    }
}
