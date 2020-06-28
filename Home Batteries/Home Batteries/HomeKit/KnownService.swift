//
//  KnownService.swift
//  Home Batteries
//
//  Created by Max Obermeier on 22.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import SwiftUI

extension HMService {
    func known() -> KnownService? {
        return ControllerService.any(self)
    }
}

extension Array where Element == HMCharacteristic {
    func known() -> [KnownCharacteristic] {
        return self.map({c in c.known()}).filter({c in c != nil}).map({c in c!})
    }
    
    func typed<T : KnownCharacteristic>() -> [T] {
        return self.map({c in c.known() as? T }).filter({c in c != nil}).map({c in c!})
    }
}

protocol KnownHomeKitEntity {
    // uuid of primary entity of entityType
    static var uuid: String { get }
    static var entityType: String { get }
}

extension KnownHomeKitEntity {
    var name: String {
        get {
            return Self.entityType
        }
    }
}

protocol KnownService: KnownHomeKitEntity {
    static var required: [KnownCharacteristic.Type] { get }
    static var optional: [KnownCharacteristic.Type] { get }
    
    var service: HMService { get }
    
    init(_ service: HMService)
}

extension KnownService {
    static func instance(_ service: HMService) -> KnownService? {
        if Self.uuid == service.serviceType {
            return Self.init(service)
        }
        return nil
    }
}

extension KnownService {
    static func any(_ service: HMService) -> KnownService? {
        return ControllerService.instance(service) ?? ElectricityMeterService.instance(service) ?? KoogeekElectricityMeterService.instance(service) ?? EnergyStorageService.instance(service) ?? OutletService.instance(service)
    }
}

extension KnownService {
    static func name(_ service: HMService) -> String {
        return service.name
    }
    
    var name: String {
        get {
            return self.service.name
        }
    }
}

// MARK: Implementations

class ControllerService: KnownService {
    internal static let uuid: String = "00000001-0000-1000-8000-0036AC324978"
    static let entityType: String = "Controller"
    static let required: [KnownCharacteristic.Type] = [StatusFault.self]
    static let optional: [KnownCharacteristic.Type] = [Name.self]
    
    var service: HMService
    
    var statusFault: StatusFault {
        return self.service.characteristics.typed().first!
    }
    
    required init(_ service: HMService) {
        self.service = service
    }
    
}

class ElectricityMeterService: KnownService {
    internal static let uuid: String = "00000002-0000-1000-8000-0036AC324978"
    static let entityType: String = "Meter"
    static let required: [KnownCharacteristic.Type] = [CurrentPower.self]
    static let optional: [KnownCharacteristic.Type] = [CurrentPowerL1.self, CurrentPowerL2.self, CurrentPowerL3.self, Name.self, ElectricityMeterType.self]
    
    var service: HMService
    
    var power: CurrentPower {
        return self.service.characteristics.typed().first!
    }
    
    var lines: (CurrentPowerL1, CurrentPowerL2, CurrentPowerL3)? {
        if let l1 : CurrentPowerL1 = self.service.characteristics.typed().first {
            if let l2 : CurrentPowerL2 = self.service.characteristics.typed().first {
                if let l3 : CurrentPowerL3 = self.service.characteristics.typed().first {
                    return (l1, l2, l3)
                }
            }
        }
        return nil
    }
    
    var type: ElectricityMeterType? {
        return self.service.characteristics.typed().first
    }
    
    required init(_ service: HMService) {
        self.service = service
    }
    
    
}

class KoogeekElectricityMeterService: ElectricityMeterService {
    internal static let secondaryUUID: String = "4AAAF930-0DEC-11E5-B939-0800200C9A66"
    
    static func instance(_ service: HMService) -> KnownService? {
        if Self.secondaryUUID == service.serviceType {
            return Self.init(service)
        }
        return nil
    }
}

class EnergyStorageService: KnownService {
    internal static let uuid: String = "00000003-0000-1000-8000-0036AC324978"
    static let entityType: String = "Home Battery"
    static let required: [KnownCharacteristic.Type] = [BatteryLevel.self, ChargingState.self, StatusLowBattery.self]
    static let optional: [KnownCharacteristic.Type] = [EnergyCapacity.self, Name.self]
    
    var service: HMService
    
    var batteryLevel: BatteryLevel {
        return self.service.characteristics.typed().first!
    }
    
    var chargingState: ChargingState {
        return self.service.characteristics.typed().first!
    }
    
    var statusLowBattery: StatusLowBattery {
        return self.service.characteristics.typed().first!
    }
    
    var energyCapacity: EnergyCapacity? {
        return self.service.characteristics.typed().first
    }
    
    required init(_ service: HMService) {
        self.service = service
    }
    
}

class OutletService: KnownService {
    internal static let uuid: String = "00000047-0000-1000-8000-0026BB765291"
    static let entityType: String = "Outlet"
    static let required: [KnownCharacteristic.Type] = [On.self, OutletInUse.self]
    static let optional: [KnownCharacteristic.Type] = [Name.self]
    
    var service: HMService
    
    var on: On {
        return self.service.characteristics.typed().first!
    }
    
    var outletInUse: OutletInUse {
        return self.service.characteristics.typed().first!
    }
    
    required init(_ service: HMService) {
        self.service = service
    }
}
