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
    func observable<T>(updating: Bool = true) -> Characteristic<T> {
        return Characteristic(self, updating: updating, initialized: Cache.shared.get(self.uniqueIdentifier))
    }

}

extension KnownCharacteristic {
    func observable<T>(updating: Bool = true) -> Characteristic<T> {
        return self.characteristic.observable(updating: updating)
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
    
    let callback: (T?) -> ()
    
    /// Initializes this Characteristic based on the given HMCharacteristic and enables notifications for the
    /// underlying value if requested.
    init(_ characteristic: HMCharacteristic, updating subscribe: Bool = false, callback: @escaping (T?) -> () = { _ in}, initialized initialValue: T? = nil) {
        self.characteristic = characteristic
        self.service = self.characteristic!.service!
        self.accessory = self.service!.accessory!
        self.subscribe = subscribe
        self.value = initialValue
        self.present = true
        self.callback = callback
        
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
        self.callback = { _ in}
        
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
                }
            })
        }
    }
    
    func reload() {
        if !self.present {
            return
        }
        self.characteristic!.readValue(completionHandler: {err in
            if let error = err {
                print("error reading value for \(self.characteristic!.characteristicType): \(error)")
            } else {
                print("red value for characteristic \(self.characteristic!.characteristicType): \(self.characteristic!.value ?? "nil")")
                self.value = self.convert(self.characteristic!.value)
                Cache.shared.set(self)
            }
        })
        if self.subscribe! && !self.characteristic!.isNotificationEnabled {
            self.characteristic!.enableNotification(true, completionHandler: {err in
                print("enabled notification for \(self.characteristic!.characteristicType)")
                if let error = err {
                    print("error enabling notification for \(self.characteristic!.characteristicType): \(error)")
                }
            })
        }
    }
    
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        guard accessory == self.accessory && service == self.service && characteristic == self.characteristic else { return }
//        print("received update for value for characteristic \(self.characteristic!.characteristicType): \(self.characteristic!.value ?? "nil")")
        self.value = self.convert(characteristic.value)
        self.callback(self.value)
        Cache.shared.set(self)
    }
    
    private func convert(_ value: Any?) -> T? {
        if let v = value {
            switch v {
            case let n as NSNumber:
                switch T.self {
                case is Float.Type:
                    return (n.floatValue as! T)
                default:
                    return (v as! T)
                }
            default:
                return (v as! T)
            }
        } else {
            return nil
        }
    }
    
}

private class Cache {
    
    static let shared = Cache()
    
    private var cache: [UUID: Any] = [:]
    
    init() {}
    
    func get<T>(_ uniqueIdentifier: UUID) -> T? {
        return cache[uniqueIdentifier] as? T
    }
    
    func set<T>(_ characteristic: Characteristic<T>) {
        guard characteristic.present else { return }
        if let v = characteristic.value {
            cache[characteristic.characteristic!.uniqueIdentifier] = (v as Any)
        }
    }
}
