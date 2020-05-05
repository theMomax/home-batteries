//
//  Characteristic.swift
//  Home Batteries
//
//  Created by Max Obermeier on 03.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//


import HomeKit
import Combine

protocol ValueBinding {
    
    associatedtype T
    
    var value: T? {get}
    var published: Published<T?> {get}
    var publisher: Published<T?>.Publisher {get}
}

/// - Tag: Characteristic
class Characteristic<T>: NSObject, ObservableObject, HMAccessoryDelegate {
    
    private let accessory: HMAccessory
    
    private let service: HMService
    
    let characteristic: HMCharacteristic
    
    @Published var value: T?
    
    init(_ characteristic: HMCharacteristic, updating subscribe: Bool = false) {
        self.characteristic = characteristic
        self.service = self.characteristic.service!
        self.accessory = self.service.accessory!
        self.value = nil
        
        super.init()
        
        self.accessory.delegate = HomeStore.shared
        
        HomeStore.shared.addAccessoryDelegate(self)
        
        self.reload()
        
        if subscribe {
            self.characteristic.enableNotification(true, completionHandler: {err in
                print("enabled notification for \(self.characteristic.characteristicType)")
                if let error = err {
                    print(error)
                    self.value = nil
                }
            })
        }
    }
    
    deinit {
        if self.characteristic.isNotificationEnabled {
            self.characteristic.enableNotification(false, completionHandler: {err in
                print("disabled notification for \(self.characteristic.characteristicType)")
                if let error = err {
                    print(error)
                    self.value = nil
                }
            })
        }
        
        HomeStore.shared.removeAccessoryDelegate(self)
    }
    
    func reload() {
        self.characteristic.readValue(completionHandler: {err in
            if let error = err {
                print(error)
                self.value = nil
            } else {
                self.value = self.characteristic.value as! T?
            }
        })
    }
    
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        guard accessory == self.accessory && service == self.service && characteristic == self.characteristic else { return }
        self.value = characteristic.value as! T?
    }
    
}

