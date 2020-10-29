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
    
    func updateDescription(_ value: Any?) -> String?
    
    func isValid(value: Any?) -> Bool?
}

// MARK: instance
extension KnownCharacteristic {
    static func instance(_ characteristic: HMCharacteristic) -> KnownCharacteristic? {
        if Self.uuid == characteristic.characteristicType {
            return Self.init(characteristic)
        }
        return nil
    }
}

// MARK: any
extension KnownCharacteristic {
    static func any(_ characteristic: HMCharacteristic) -> KnownCharacteristic? {
        return [
            CurrentPower.instance,
            KoogeekCurrentPower.instance,
            CurrentPowerL1.instance,
            CurrentPowerL2.instance,
            CurrentPowerL3.instance,
            EnergyCapacity.instance,
            ElectricityMeterType.instance,
            Name.instance,
            BatteryLevel.instance,
            ChargingState.instance,
            StatusLowBattery.instance,
            StatusFault.instance,
            On.instance,
            OutletInUse.instance,
            EstimatedRange.instance,
            Active.instance,
            HourlyEnergyToday.instance,
            HourlyEnergyYesterday.instance,
            HourlyEnergy2DaysAgo.instance,
            HourlyEnergy3DaysAgo.instance,
            HourlyEnergy4DaysAgo.instance,
            HourlyEnergy5DaysAgo.instance,
            HourlyEnergy6DaysAgo.instance,
            HourlyEnergy7DaysAgo.instance,
            DailyEnergyThisMonth.instance,
            DailyEnergyLastMonth.instance,
            MonthlyEnergyThisYear.instance,
            MonthlyEnergyLastYear.instance,
            ].map( { i in i(characteristic)}).reduce(nil, {(a, b) in a ?? b})
    }
}

// MARK: name
extension KnownCharacteristic {
    static func name(_ characteristic: HMCharacteristic) -> String {
        return (CurrentPower.any(characteristic)?.name ?? characteristic.localizedDescription)
    }
}

// MARK: description
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
    
    static func serviceDescription(_ characteristic: HMCharacteristic) -> String {
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
    
    static func accessoryDescription(_ characteristic: HMCharacteristic, ending final: Bool = false) -> String {
        if final {
            return characteristic.service!.accessory!.name
        } else {
            return characteristic.service!.accessory!.name + "'s "
        }
    }
}

// MARK: unit
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


// MARK: format
extension KnownCharacteristic {
    private static func genericFormat(of value: Any) -> String? {
        switch value {
        case let f as Float:
            return String(format: "%.0f", f)
        case let d as Double:
            return String(format: "%.0f", d)
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
            return "unknown"
        }
    }
    
    static func format(_ value: Any?, as characteristic: HMCharacteristic) -> String {
        if let c = CurrentPower.any(characteristic) {
            return c.format(value)
        } else {
            if let v = value {
                return Self.genericFormat(of: v) ?? "unknown"
            } else {
                return "unknown"
            }
        }
    }
}

// MARK: isContinuous
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

// MARK: isValid
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

// MARK: updateDescription
extension KnownCharacteristic {
    func updateDescription(_ value: Any?) -> String? {
        return "\(self.description) is set to \(self.format(value))"
    }
}

extension KnownCharacteristic {
    func updateDescription(_ value: Any?) -> String {
        return self.updateDescription(value) ?? "Unknown value is changed"
    }
}


// MARK: Generic Implementations


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

class Range {
    static func unit() -> String? {
        return "km"
    }
}

class HourlyEnergy: Energy {
    static func format(of value: Any) -> String? {
        if let data = value as? Double {
            return String(format: "%.2f", data)
        }
        return nil
    }
}

class DailyEnergy: Energy {
    static func format(of value: Any) -> String? {
        if let data = value as? Double {
            return String(format: "%.1f", data)
        }
        return nil
    }
}

class MonthlyEnergy: Energy {
    static func format(of value: Any) -> String? {
        if let data = value as? Double {
            return String(format: "%.0f", data)
        }
        return nil
    }
}
