//
//  KnownCharacteristic.swift
//  Home Batteries
//
//  Created by Max Obermeier on 22.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit

extension HMCharacteristic {
    func known() -> KnownCharacteristic? {
        return CurrentPower.any(self)
    }
}

protocol KnownCharacteristic: KnownHomeKitEntity {
    var characteristic: HMCharacteristic { get }
    
    init(_ characteristic: HMCharacteristic)
    
    static func unit() -> String?
    
    static func format(of value: Any) -> String?
    
    func isValid(value: Any?) -> Bool?
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
        case StatusFault.uuid:
            return StatusFault(characteristic)
        default:
            return nil
        }
    }
}

extension KnownCharacteristic {
    static func name(_ characteristic: HMCharacteristic) -> String {
        return (CurrentPower.any(characteristic)?.name ?? characteristic.localizedDescription)
    }
}

extension KnownCharacteristic {
    var description: String {
        return Self.description(characteristic)
    }
    
    static func description(_ characteristic: HMCharacteristic) -> String {
        return Self.name(characteristic) + " of " + serviceDescription(characteristic)
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

extension KnownCharacteristic {
    private static func genericFormat(of value: Any) -> String? {
        switch value {
        case let c as CustomStringConvertible:
            return c.description
        default:
            return nil
        }
    }
    
    static func format(of value: Any) -> String? {
        return Self.genericFormat(of: value)
    }
}

extension KnownCharacteristic {
    
    func format(_ value: Any?) -> String {
        return Self.format(value)
    }
    
    static func format(_ value: Any?) -> String {
        if let v = value {
            return Self.format(of: v) ?? "unknown"
        } else {
            return "unset"
        }
    }
    
    static func format(_ value: Any?, as characteristic: HMCharacteristic) -> String {
        if let c = CurrentPower.any(characteristic) {
            return c.format(value)
        } else {
            if let v = value {
                return Self.genericFormat(of: v) ?? "unknown"
            } else {
                return "unset"
            }
        }
    }
}

extension KnownCharacteristic {
    var isContinuous: Bool? {
        if let m = self.characteristic.metadata {
            if let f = m.format {
                switch f {
                case HMCharacteristicMetadataFormatString:
                    return nil
                case HMCharacteristicMetadataFormatInt,
                     HMCharacteristicMetadataFormatFloat:
                    return true
                default:
                    return m.validValues == nil || m.validValues!.count >= 10
                }
            } else {
                return m.validValues == nil
            }
        } else {
            return nil
        }
    }
    
    static func isContinuous(_ characteristic: HMCharacteristic) -> Bool? {
        return CurrentPower.any(characteristic)?.isContinuous
    }
}

extension KnownCharacteristic {
    func isValid(value: Any?) -> Bool? {
        if let v = value {
            if let m = self.characteristic.metadata {
                if let f = m.format {
                    switch f {
                    case HMCharacteristicMetadataFormatInt,
                         HMCharacteristicMetadataFormatFloat:
                        if let n = v as? NSNumber {
                            return (m.maximumValue == nil || m.maximumValue!.floatValue >= n.floatValue) && (m.minimumValue == nil || m.minimumValue!.floatValue <= n.floatValue)
                        } else if let s = v as? String {
                            if let f = Float(s) {
                                return (m.maximumValue == nil || m.maximumValue!.floatValue >= f) && (m.minimumValue == nil || m.minimumValue!.floatValue <= f)
                            } else {
                                return false
                            }
                        } else {
                            return false
                        }
                    case HMCharacteristicMetadataFormatString:
                        return nil
                    default:
                        if let n = v as? NSNumber {
                            return m.validValues?.contains(n)
                        } else if let s = v as? String {
                            if let f = Float(s) {
                                return (m.validValues == nil || m.validValues!.contains(NSNumber(value: f))) && ((m.maximumValue == nil || m.maximumValue!.floatValue >= f) && (m.minimumValue == nil || m.minimumValue!.floatValue <= f))
                            } else {
                                return false
                            }
                        } else {
                            return false
                        }
                    }
                } else {
                    switch v {
                    case let n as NSNumber:
                        return m.validValues?.contains(n)
                    default:
                        return nil
                    }
                }
            } else {
                return nil
            }
        } else {
            return false
        }
    }
}

extension KnownCharacteristic {
    func isValid(_ value: Any?) -> Bool {
        return isValid(value: value) ?? false
    }
    
    static func isValid(_ value: Any?, for characteristic: HMCharacteristic) -> Bool {
        return CurrentPower.any(characteristic)?.isValid(value) ?? false
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

class EnergyCapacity: Energy, KnownCharacteristic {
    static let uuid: String = "00000005-0001-1000-8000-0036AC324978"
    static let entityType: String = "Capacity"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

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
        default:
            return nil
        }
    }
    
}

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
}

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

class BatteryLevel: Percentage, KnownCharacteristic {
    static let uuid: String = "00000068-0000-1000-8000-0026BB765291"
    static let entityType: String = "Battery Level"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

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
}

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
}
