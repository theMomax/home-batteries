//
//  KnownCharacteristic.swift
//  Home Batteries
//
//  Created by Max Obermeier on 22.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit

protocol KnownCharacteristic: KnownHomeKitEntity {
    var characteristic: HMCharacteristic { get }
    
    init(_ characteristic: HMCharacteristic)
    
    static func unit() -> String?
}

extension KnownCharacteristic {
    static func any(_ characteristic: HMCharacteristic) -> KnownCharacteristic? {
        switch characteristic.characteristicType {
        case CurrentPower.uuid:
            return CurrentPower(characteristic)
        case CurrentPowerL1.uuid:
            return CurrentPowerL1(characteristic)
        case CurrentPowerL2.uuid:
            return CurrentPowerL2(characteristic)
        case CurrentPowerL3.uuid:
            return CurrentPowerL3(characteristic)
        case EnergyCapacity.uuid:
            return EnergyCapacity(characteristic)
        case ElectricityMeterType.uuid:
            return ElectricityMeterType(characteristic)
        case Name.uuid:
            return Name(characteristic)
        case BatteryLevel.uuid:
            return BatteryLevel(characteristic)
        case ChargingState.uuid:
            return ChargingState(characteristic)
        case StatusLowBattery.uuid:
            return StatusLowBattery(characteristic)
        default:
            return nil
        }
    }
}

extension KnownCharacteristic {
    func description() -> String {
        return Self.description(characteristic)
    }
    
    static func description(_ characteristic: HMCharacteristic) -> String {
        return (CurrentPower.any(characteristic)?.name ?? "Value") + " of " + serviceDescription(characteristic)
    }
    
    private static func multiple(of characteristic: HMCharacteristic, in accessory: HMAccessory) -> Bool {
        return accessory.services.filter({ (service: HMService) in service.characteristics.contains(where: { (c: HMCharacteristic) in c.characteristicType == characteristic.characteristicType }) }).count > 1
    }
    
    private static func serviceDescription(_ characteristic: HMCharacteristic) -> String {
        if characteristic.service == nil  {
            return "unknown origin"
        } else if characteristic.service!.accessory == nil {
            return ControllerService.any(characteristic.service!)?.name ?? characteristic.service!.name
        } else if multiple(of: characteristic, in: characteristic.service!.accessory!) {
            return self.accessoryDescription(characteristic) + (ControllerService.any(characteristic.service!)?.name ?? characteristic.service!.name)
        } else {
            return self.accessoryDescription(characteristic, ending: true)
        }
    }
    
    private static func accessoryDescription(_ characteristic: HMCharacteristic, ending final: Bool = false) -> String {
        if final {
            return characteristic.service!.accessory!.name
        } else {
            return characteristic.service!.accessory!.name + "'s "
        }
    }
}

extension KnownCharacteristic {
    static func unit() -> String? {
        return nil
    }
}

extension KnownCharacteristic {
    func unit() -> String {
        return Self.unit() ?? characteristic.metadata?.units ?? ""
    }
    
    static func unit(_ characteristic: HMCharacteristic) -> String {
        return CurrentPower.any(characteristic)?.unit() ?? ""
    }
}

class Power {
    static func unit() -> String? {
        return "W"
    }
}

class Energy {
    static func unit() -> String? {
        return "kWh"
    }
}

class Percentage {
    static func unit() -> String? {
        return "%"
    }
}

class CurrentPower: Power, KnownCharacteristic {
    static var uuid: String = "00000001-0001-1000-8000-0036AC324978"
    static let entityType: String = "Power"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class CurrentPowerL1: Power, KnownCharacteristic {
    static var uuid: String = "00000002-0001-1000-8000-0036AC324978"
    static let entityType: String = "Power L1"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class CurrentPowerL2: Power, KnownCharacteristic {
    static var uuid: String = "00000003-0001-1000-8000-0036AC324978"
    static let entityType: String = "Power L2"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class CurrentPowerL3: Power, KnownCharacteristic {
    static var uuid: String = "00000004-0001-1000-8000-0036AC324978"
    static let entityType: String = "Power L3"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class EnergyCapacity: Energy, KnownCharacteristic {
    static var uuid: String = "00000005-0001-1000-8000-0036AC324978"
    static let entityType: String = "Capacity"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class ElectricityMeterType: KnownCharacteristic {
    static var uuid: String = "00000006-0001-1000-8000-0036AC324978"
    static let entityType: String = "Meter Type"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class StatusFault: KnownCharacteristic {
    static var uuid: String = "00000077-0000-1000-8000-0026BB765291"
    static let entityType: String = "Fault"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class Name: KnownCharacteristic {
    static var uuid: String = "00000023-0000-1000-8000-0026BB765291"
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

class BatteryLevel: Percentage, KnownCharacteristic {
    static var uuid: String = "00000068-0000-1000-8000-0026BB765291"
    static let entityType: String = "Battery Level"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class ChargingState: KnownCharacteristic {
    static var uuid: String = "0000008F-0000-1000-8000-0026BB765291"
    static let entityType: String = "Charging"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class StatusLowBattery: KnownCharacteristic {
    static var uuid: String = "00000079-0000-1000-8000-0026BB765291"
    static let entityType: String = "Low Battery"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}
