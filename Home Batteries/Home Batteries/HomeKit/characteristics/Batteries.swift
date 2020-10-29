//
//  Batteries.swift
//  Home Batteries
//
//  Created by Max Obermeier on 29.10.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit

// MARK: Current Power
class CurrentPower: Power, KnownCharacteristic {
    static let uuid: String = "00000001-0001-1000-8000-0036AC324978"
    static let entityType: String = "Power"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class CurrentPowerL1: Power, KnownCharacteristic {
    static let uuid: String = "00000002-0001-1000-8000-0036AC324978"
    static let entityType: String = "Power L1"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class CurrentPowerL2: Power, KnownCharacteristic {
    static let uuid: String = "00000003-0001-1000-8000-0036AC324978"
    static let entityType: String = "Power L2"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class CurrentPowerL3: Power, KnownCharacteristic {
    static let uuid: String = "00000004-0001-1000-8000-0036AC324978"
    static let entityType: String = "Power L3"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

// MARK: Energy Capacity
class EnergyCapacity: Energy, KnownCharacteristic {
    static let uuid: String = "00000005-0001-1000-8000-0036AC324978"
    static let entityType: String = "Capacity"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}


// MARK: Electricity Meter Type
class ElectricityMeterType: KnownCharacteristic {
    static let uuid: String = "00000006-0001-1000-8000-0036AC324978"
    static let entityType: String = "Meter Type"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
    static func format(of value: Any) -> String? {
        switch value {
        case 1 as UInt8:
            return "production"
        case 2 as UInt8:
            return "consumption"
        case 3 as UInt8:
            return "storage"
        case 4 as UInt8:
            return "grid"
        case 5 as UInt8:
            return "excess"
        default:
            return nil
        }
    }
    
    static let allCases: [UInt8] = [0, 1, 2, 3, 4, 5]
    
    static let other: UInt8 = 0
    
    static let production: UInt8 = 1
    
    static let consumption: UInt8 = 2
    
    static let storage: UInt8 = 3
    
    static let grid: UInt8 = 4
    
    static let excess: UInt8 = 5
    
}
