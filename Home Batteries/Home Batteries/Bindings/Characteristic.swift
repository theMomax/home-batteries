//
//  Characteristic.swift
//  Home Batteries
//
//  Created by Max Obermeier on 03.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//


import HomeKit
import Combine


extension HMCharacteristic {
    func observable<T>(_ updating: Bool = true) -> Characteristic<T> {
        return Characteristic(self, updating: updating)
    }
}

extension KnownCharacteristic {
    func observable<T>(_ updating: Bool = true) -> Characteristic<T> {
        return self.characteristic.observable(updating)
    }
}

/// - Tag: Characteristic
class Characteristic<T>: NSObject, ObservableObject, HMAccessoryDelegate {
    
    private let accessory: HMAccessory?
    
    private let service: HMService?
    
    private let subscribe: Bool?
    
    let characteristic: HMCharacteristic?
    
    @Published var value: T?
    
    let present: Bool
    
    /// Initializes this Characteristic based on the given HMCharacteristic and enables notifications for the
    /// underlying value if requested.
    init(_ characteristic: HMCharacteristic, updating subscribe: Bool = false) {
        self.characteristic = characteristic
        self.service = self.characteristic!.service!
        self.accessory = self.service!.accessory!
        self.subscribe = subscribe
        self.value = nil
        self.present = true
        
        super.init()
        
        self.accessory!.delegate = HomeStore.shared
        
        HomeStore.shared.addAccessoryDelegate(self)
        
        self.reload()
    }
    
    /// Initializes this Characteristic as non-present.
    override init() {
        self.characteristic = nil
        self.service = nil
        self.accessory = nil
        self.subscribe = nil
        self.value = nil
        self.present = false
        
        super.init()
    }
    
    deinit {
        print("deinit characteristic")
        pause()
        
        HomeStore.shared.removeAccessoryDelegate(self)
    }
    
    func pause() {
        if !self.present {
            return
        }
        if self.characteristic!.isNotificationEnabled {
            self.characteristic!.enableNotification(false, completionHandler: {err in
                print("disabled notification for \(self.characteristic!.characteristicType)")
                if let error = err {
                    print("error disabling notification for \(self.characteristic!.characteristicType): \(error)")
                    self.value = nil
                }
            })
        }
    }
    
    func reload() {
        if !self.present {
            return
        }
        self.value = nil
        self.characteristic!.readValue(completionHandler: {err in
            if let error = err {
                print("error reading value for \(self.characteristic!.characteristicType): \(error)")
                self.value = nil
            } else {
                print("red value for characteristic \(self.characteristic!.characteristicType): \(self.characteristic!.value ?? "nil")")
                self.value = self.characteristic!.value as! T?
            }
        })
        if self.subscribe! && !self.characteristic!.isNotificationEnabled {
            self.characteristic!.enableNotification(true, completionHandler: {err in
                print("enabled notification for \(self.characteristic!.characteristicType)")
                if let error = err {
                    print("error enabling notification for \(self.characteristic!.characteristicType): \(error)")
                    self.value = nil
                }
            })
        }
    }
    
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        guard accessory == self.accessory && service == self.service && characteristic == self.characteristic else { return }
        // print("received update for value for characteristic \(self.characteristic!.characteristicType): \(self.characteristic!.value ?? "nil")")
        self.value = characteristic.value as! T?
    }
    
}

