//
//  Koogeek.swift
//  Home Batteries
//
//  Created by Max Obermeier on 29.10.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit

// MARK: Current Power

class KoogeekCurrentPower: CurrentPower {
    static let secondaryUUID: String = "4AAAF931-0DEC-11E5-B939-0800200C9A66"
    
    static func instance(_ characteristic: HMCharacteristic) -> KnownCharacteristic? {
        if Self.secondaryUUID == characteristic.characteristicType {
            return Self.init(characteristic)
        }
        return nil
    }
}


// MARK: Hourly Energy
class KoogeekHourlyEnergy: Energy {
    
    static func format(of value: Any) -> String? {
        if let data = value as? NSData {
            return self.extract(from: data)?.description
        }
        return HourlyEnergy.format(of: value)
    }
    
    static func extract(from data: NSData) -> [Double]? {
        if data.length == 98 {
            if data.bytes.load(fromByteOffset: 0, as: UInt8.self) == UInt8(0) && data.bytes.load(fromByteOffset: 1, as: UInt8.self) == UInt8(24 * 4) {
                var bytes = [UInt8](repeating: 0, count: 96)
                for i in bytes.indices {
                    bytes[i] = data.bytes.load(fromByteOffset: 2 + i, as: UInt8.self)
                }
                var values = [Float32](repeating: 0, count: 24)
                for i in values.indices {
                    values[i] = Array(bytes[4*i..<4*(i+1)]).withUnsafeBufferPointer {
                        $0.baseAddress!.withMemoryRebound(to: Float32.self, capacity: 1) {
                            $0.pointee
                        }
                    }
                    values[i] /= 1000.0
                }
                return values.map({ f in Double(f)})
            }
        }
        
        return nil
    }
    
}

class HourlyEnergyToday: KoogeekHourlyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF933-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Hourly Energy Today"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class HourlyEnergyYesterday: KoogeekHourlyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF934-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Hourly Energy Yesterday"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class HourlyEnergy2DaysAgo: KoogeekHourlyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF935-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Hourly Energy two days ago"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class HourlyEnergy3DaysAgo: KoogeekHourlyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF936-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Hourly Energy three days ago"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class HourlyEnergy4DaysAgo: KoogeekHourlyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF937-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Hourly Energy four days ago"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class HourlyEnergy5DaysAgo: KoogeekHourlyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF938-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Hourly Energy five days ago"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class HourlyEnergy6DaysAgo: KoogeekHourlyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF939-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Hourly Energy six days ago"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class HourlyEnergy7DaysAgo: KoogeekHourlyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF93A-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Hourly Energy seven days ago"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}



// MARK: Daily Energy
class KoogeekDailyEnergy: Energy {
    
    static func format(of value: Any) -> String? {
        if let data = value as? NSData {
            return self.extract(from: data)?.description
        }
        return DailyEnergy.format(of: value)
    }
    
    static func extract(from data: NSData) -> [Double]? {
        guard data.length == 2 + 4 * 31 else { return nil }
        var bytes: [UInt8] = []
        for i in 2..<data.length {
            bytes.append(data.bytes.load(fromByteOffset: i, as: UInt8.self))
        }
        var values: [Float32] = []
        for i in 0..<bytes.count/4 {
            values.append(Array(bytes[4*i..<4*(i+1)]).withUnsafeBufferPointer {
                $0.baseAddress!.withMemoryRebound(to: Float32.self, capacity: 1) {
                    $0.pointee
                }
            })
            values[i] /= 1000.0
        }
        return values.map({ f in Double(f)})
    }
    
}

class DailyEnergyThisMonth: KoogeekDailyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF93B-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Daily Energy of this month"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class DailyEnergyLastMonth: KoogeekDailyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF93C-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Daily Energy of last month"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

// MARK: Monthly Energy
class KoogeekMonthlyEnergy: Energy {
    
    static func format(of value: Any) -> String? {
        if let data = value as? NSData {
            return self.extract(from: data)?.description
        }
        return MonthlyEnergy.format(of: value)
    }
    
    static func extract(from data: NSData) -> [Double]? {
        guard data.length == 2 + 4 * 12 else { return nil }
        var bytes: [UInt8] = []
        for i in 2..<data.length {
            bytes.append(data.bytes.load(fromByteOffset: i, as: UInt8.self))
        }
        var values: [Float32] = []
        for i in 0..<bytes.count/4 {
            values.append(Array(bytes[4*i..<4*(i+1)]).withUnsafeBufferPointer {
                $0.baseAddress!.withMemoryRebound(to: Float32.self, capacity: 1) {
                    $0.pointee
                }
            })
            values[i] /= 1000.0
        }
        return values.map({ f in Double(f)})
    }
    
}

class MonthlyEnergyThisYear: KoogeekMonthlyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF93D-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Monthly Energy of this year"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}

class MonthlyEnergyLastYear: KoogeekMonthlyEnergy, KnownCharacteristic {
    static let uuid: String = "4AAAF93E-0DEC-11E5-B939-0800200C9A66"
    static let entityType: String = "Monthly Energy of last year"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}
