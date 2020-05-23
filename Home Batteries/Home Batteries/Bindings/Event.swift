//
//  Event.swift
//  Home Batteries
//
//  Created by Max Obermeier on 22.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Combine
import HomeKit

/// - Tag: Event
class Event<T: HMEvent>: NSObject, ObservableObject, HMHomeDelegate {
    
    let home: HMHome
    
    @Published var value: T
    
    init(_ event: T, in home: HMHome) {
        self.value = event
        self.home = home
        
        super.init()
        
        self.home.delegate = HomeStore.shared
        
        HomeStore.shared.addHomeDelegate(self)
    }
    
    deinit {
        HomeStore.shared.removeHomeDelegate(self)
    }
    
    func home(_ home: HMHome, didUpdate trigger: HMTrigger) {
        guard home == self.home && self.value == trigger else { return }
        self.objectWillChange.send()
    }
}

class CharacteristicEvent<T: HMCharacteristicEvent<NSCopying>>: Event<T>, HMAccessoryDelegate {

    
    func accessoryDidUpdateName(_ accessory: HMAccessory) {
        guard accessory == self.value.characteristic.service else { return }
        self.objectWillChange.send()
    }
    
    func accessory(_ accessory: HMAccessory, didUpdateNameFor service: HMService) {
        guard accessory == self.value.characteristic.service else { return }
        self.objectWillChange.send()
    }
    
    func accessory(_ accessory: HMAccessory, didUpdateAssociatedServiceTypeFor service: HMService) {
        guard accessory == self.value.characteristic.service else { return }
        self.objectWillChange.send()
    }
    
    func accessoryDidUpdateServices(_ accessory: HMAccessory) {
        guard accessory == self.value.characteristic.service else { return }
        self.objectWillChange.send()
    }
}
