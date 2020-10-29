//
//  Apple.swift
//  Home Batteries
//
//  Created by Max Obermeier on 29.10.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit

// MARK: Status Fault
class StatusFault: KnownCharacteristic {
    static let uuid: String = "00000077-0000-1000-8000-0026BB765291"
    static let entityType: String = "Status Fault"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
    static func format(of value: Any) -> String? {
        switch value {
        case 0 as UInt8:
            return "no fault"
        case 1 as UInt8:
            return "general fault"
        default:
            return nil
        }
    }
    
    static let allCases: [UInt8] = [0, 1]
    
    static let noFault: UInt8 = 0
    
    static let generalFault: UInt8 = 1
}


// MARK: Name
class Name: KnownCharacteristic {
    static let uuid: String = "00000023-0000-1000-8000-0026BB765291"
    static let entityType: String = "Name"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
    var name: String {
        get {
            self.characteristic.value as? String ?? Self.entityType
        }
    }
}

// MARK: Battery Level
class BatteryLevel: Percentage, KnownCharacteristic {
    static let uuid: String = "00000068-0000-1000-8000-0026BB765291"
    static let entityType: String = "Battery Level"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

// MARK: Charging State
class ChargingState: KnownCharacteristic {
    static let uuid: String = "0000008F-0000-1000-8000-0026BB765291"
    static let entityType: String = "Charging State"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
    static func format(of value: Any) -> String? {
        switch value {
        case 0 as UInt8:
            return "not charging"
        case 1 as UInt8:
            return "charging"
        case 2 as UInt8:
            return "not chargeable"
        default:
            return nil
        }
    }
    
    static let allCases: [UInt8] = [0, 1, 2]
    
    static let notCharging: UInt8 = 0
    
    static let charging: UInt8 = 1
    
    static let notChargeable: UInt8 = 2
}

// MARK: Status Low Battery
class StatusLowBattery: KnownCharacteristic {
    static let uuid: String = "00000079-0000-1000-8000-0026BB765291"
    static let entityType: String = "Low Battery"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
    static func format(of value: Any) -> String? {
        switch value {
        case 0 as UInt8:
            return "normal"
        case 1 as UInt8:
            return "low"
        default:
            return nil
        }
    }
    
    static let allCases: [UInt8] = [0, 1]
    
    static let normal: UInt8 = 0
    
    static let low: UInt8 = 1
}


// MARK: On
class On: KnownCharacteristic {
    static var uuid: String = "00000025-0000-1000-8000-0026BB765291"
    static var entityType: String = "On"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
    static func format(of value: Any) -> String? {
        switch value {
        case true as Bool:
            return "on"
        case false as Bool:
            return "off"
        default:
            return nil
        }
    }
    
    func updateDescription(_ value: Any?) -> String? {
        if let on = value as? Bool {
            return "\(Self.accessoryDescription(self.characteristic, ending: true)) is turned \(self.format(on))"
        } else {
            return nil
        }
    }
}

// MARK: OutletInUse
class OutletInUse: KnownCharacteristic {
    static var uuid: String = "00000026-0000-1000-8000-0026BB765291"
    static var entityType: String = "Outlet in Use"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
    static func format(of value: Any) -> String? {
        switch value {
        case true as Bool:
            return "plugged in"
        case false as Bool:
            return "not in use"
        default:
            return nil
        }
    }
}

// MARK: Active
class Active: KnownCharacteristic {
    static var uuid: String = "000000B0-0000-1000-8000-0026BB765291"
    static var entityType: String = "Is Active"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
    static func format(of value: Any) -> String? {
        switch value {
        case Self.inactive as UInt8:
            return "inactive"
        case Self.active as UInt8:
            return "active"
        default:
            return "nil"
        }
    }
    
    static let inactive: UInt8 = 0
    
    static let active: UInt8 = 1
}
