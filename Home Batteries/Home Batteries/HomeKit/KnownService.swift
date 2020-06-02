//
//  KnownService.swift
//  Home Batteries
//
//  Created by Max Obermeier on 22.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit

extension HMService {
    func known() -> KnownService? {
        return ControllerService.any(self)
    }
}

protocol KnownHomeKitEntity {
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
    static func any(_ service: HMService) -> KnownService? {
        switch service.serviceType {
        case ControllerService.uuid:
            return ControllerService(service)
        case ElectricityMeterService.uuid:
            return ElectricityMeterService(service)
        case EnergyStorageService.uuid:
            return EnergyStorageService(service)
        default:
            return nil
        }
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

class ControllerService: KnownService {
    static let uuid: String = "00000001-0000-1000-8000-0036AC324978"
    static let entityType: String = "Controller"
    static let required: [KnownCharacteristic.Type] = [StatusFault.self]
    static let optional: [KnownCharacteristic.Type] = [Name.self]
    
    var service: HMService
    
    required init(_ service: HMService) {
        self.service = service
    }
    
}

class ElectricityMeterService: KnownService {
    static let uuid: String = "00000002-0000-1000-8000-0036AC324978"
    static let entityType: String = "Meter"
    static let required: [KnownCharacteristic.Type] = [CurrentPower.self]
    static let optional: [KnownCharacteristic.Type] = [CurrentPowerL1.self, CurrentPowerL2.self, CurrentPowerL3.self, Name.self, ElectricityMeterType.self]
    
    var service: HMService
    
    required init(_ service: HMService) {
        self.service = service
    }
    
}

class EnergyStorageService: KnownService {
    static let uuid: String = "00000003-0000-1000-8000-0036AC324978"
    static let entityType: String = "Home Battery"
    static let required: [KnownCharacteristic.Type] = [BatteryLevel.self, ChargingState.self, StatusLowBattery.self]
    static let optional: [KnownCharacteristic.Type] = [EnergyCapacity.self, Name.self]
    
    var service: HMService
    
    required init(_ service: HMService) {
        self.service = service
    }
    
}
