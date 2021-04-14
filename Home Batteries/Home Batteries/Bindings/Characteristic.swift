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
    
    enum Source {
        case characteristic(HMCharacteristic)
        case `default`(T)
        case absent
    }
    
    private let accessory: HMAccessory?
    
    private let service: HMService?
    
    private let subscribe: Bool?
    
    private let source: Source
    
    var characteristic: HMCharacteristic? {
        switch self.source {
        case let .characteristic(c):
            return c
        default:
            return nil
        }
    }
    
    var present: Bool {
        switch self.source {
        case .absent:
            return false
        default:
            return true
        }
    }
    
    @Published var value: T?
    
    let callback: (T?) -> ()
    
    /// Initializes this Characteristic based on the given HMCharacteristic and enables notifications for the
    /// underlying value if requested.
    init(_ characteristic: HMCharacteristic, updating subscribe: Bool = false, callback: @escaping (T?) -> () = { _ in}, initialized initialValue: T? = nil) {
        self.source = .characteristic(characteristic)
        self.service = characteristic.service!
        self.accessory = self.service!.accessory!
        self.subscribe = subscribe
        self.value = initialValue
        self.callback = callback
        
        super.init()
        
        self.accessory!.delegate = HomeStore.shared
        
        HomeStore.shared.addAccessoryDelegate(self)
        
        self.reload()
    }
    
    /// Initializes this Characteristic as present and fixed to the given default value.
    init(using default: T? = nil) {
        if let d = `default` {
            self.source = .default(d)
        } else {
            self.source = .absent
        }
        
        self.service = nil
        self.accessory = nil
        self.subscribe = nil
        self.value = `default`
        self.callback = { _ in}
        
        super.init()
    }
    
    deinit {
        print("deinit characteristic")
        pause()
        
        HomeStore.shared.removeAccessoryDelegate(self)
    }
    
    func pause() {
        guard case let .characteristic(characteristic) = self.source else {
            return
        }
        if characteristic.isNotificationEnabled {
            characteristic.enableNotification(false, completionHandler: {err in
                print("disabled notification for \(characteristic.characteristicType)")
                if let error = err {
                    print("error disabling notification for \(characteristic.characteristicType): \(error)")
                }
            })
        }
    }
    
    func reload() {
        guard case let .characteristic(characteristic) = self.source else {
            return
        }
        characteristic.readValue(completionHandler: {err in
            if let error = err {
                print("error reading value for \(characteristic.characteristicType): \(error)")
            } else {
                print("red value for characteristic \(characteristic.characteristicType): \(characteristic.value ?? "nil")")
                self.value = self.convert(characteristic.value)
                Cache.shared.set(self)
            }
        })
        if self.subscribe! && !characteristic.isNotificationEnabled {
            characteristic.enableNotification(true, completionHandler: {err in
                print("enabled notification for \(characteristic.characteristicType)")
                if let error = err {
                    print("error enabling notification for \(characteristic.characteristicType): \(error)")
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
