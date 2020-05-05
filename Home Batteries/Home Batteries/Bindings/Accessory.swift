//
//  Accessory.swift
//  Home Batteries
//
//  Created by Max Obermeier on 03.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import Combine

/// - Tag: Accessory
class Accessory: NSObject, ObservableObject, HMAccessoryDelegate {
    
    @Published var value: HMAccessory
    
    init(_ accessory: HMAccessory) {
        self.value = accessory
        
        super.init()
        
        self.value.delegate = HomeStore.shared
        
        HomeStore.shared.addAccessoryDelegate(self)
    }
    
    deinit {
        HomeStore.shared.removeAccessoryDelegate(self)
    }
    
    func accessoryDidUpdateName(_ accessory: HMAccessory) {
        guard accessory == self.value else { return }
        self.value = accessory
    }
    
    func accessory(_ accessory: HMAccessory, didUpdateNameFor service: HMService) {
        guard accessory == self.value else { return }
        self.value = accessory
    }
    
    func accessory(_ accessory: HMAccessory, didUpdateAssociatedServiceTypeFor service: HMService) {
        guard accessory == self.value else { return }
        self.value = accessory
    }
    
    func accessoryDidUpdateServices(_ accessory: HMAccessory) {
        guard accessory == self.value else { return }
        self.value = accessory
    }
    
    func accessory(_ accessory: HMAccessory, didAdd profile: HMAccessoryProfile) {
        guard accessory == self.value else { return }
        self.value = accessory
    }
    
    func accessory(_ accessory: HMAccessory, didRemove profile: HMAccessoryProfile) {
        guard accessory == self.value else { return }
        self.value = accessory
    }
    
    func accessoryDidUpdateReachability(_ accessory: HMAccessory) {
        guard accessory == self.value else { return }
        self.value = accessory
    }
    
    func accessory(_ accessory: HMAccessory, didUpdateFirmwareVersion firmwareVersion: String) {
        guard accessory == self.value else { return }
        self.value = accessory
    }
    
}
