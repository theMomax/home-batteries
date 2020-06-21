//
//  AccessoryOverviewView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 03.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI
import HomeKit

struct AccessoryLiveView: View {
    
    static let supportedServices = [ControllerService.uuid, ElectricityMeterService.uuid, EnergyStorageService.uuid]
    
    @ObservedObject var accessory: Accessory
    
    @ViewBuilder
    var body: some View {
        WrapperView(edges: .init(arrayLiteral: .top, .horizontal)) {
            if !self.accessory.value.isReachable {
                ConnectingToAccessoryView(accessory: self.$accessory.value)
            } else {
                VStack {
                    HStack {
                        Text(self.accessory.value.name)
                        if self.hasState() {
                            TotalStateView(self.accessory.value.services.typed().first!)
                        }
                    }
                    if self.hasEnergyStorage() {
                        TotalStorageView(self.accessory.value.services.typed().first!).padding(.bottom)
                    }
                    self.metersView()
                }
            }
        }
    }
    
    private func metersView() -> some View {
        let meters = self.metersWithAllLines() + self.metersWithoutAllLines()
        
        return ForEach(0..<meters.count) { index in
            if index == 0 {
                MeterView(meters[index])
            } else {
                MeterView(meters[index]).padding(.top)
            }
        }
    }
    
    private func hasState() -> Bool {
        let cs: [ControllerService] = self.accessory.value.services.typed()
        return !cs.isEmpty
    }
    
    private func hasEnergyStorage() -> Bool {
        let es: [EnergyStorageService] = self.accessory.value.services.typed()
        return !es.isEmpty
    }
    
    private func metersWithAllLines() -> [ElectricityMeterService] {
        return self.accessory.value.services.typed().filter({s in s.lines != nil})
    }
    
    private func metersWithoutAllLines() -> [ElectricityMeterService] {
        return self.accessory.value.services.typed().filter({s in s.lines == nil})
    }
}

struct TotalStateView: View {
    
    let service: ControllerService
    
    @ObservedObject var totalState: Characteristic<UInt8>
       
    init(_ service: ControllerService) {
        self.service = service
        self.totalState = service.statusFault.observable()
    }
    
    @ViewBuilder
    var body: some View {
        ControllerServiceView(state: self.$totalState.value)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.totalState.reload()
        }
    }
    
}

struct MeterView: View {
    
    let service: ElectricityMeterService
    
    @ObservedObject var currentPower: Characteristic<Float>
    @ObservedObject var currentPowerL1: Characteristic<Float>
    @ObservedObject var currentPowerL2: Characteristic<Float>
    @ObservedObject var currentPowerL3: Characteristic<Float>
    @ObservedObject var meterType: Characteristic<UInt8>
       
    init(_ service: ElectricityMeterService) {
        self.service = service

        self.currentPower = service.power.observable()
        
        if let (l1, l2, l3) = service.lines {
            self.currentPowerL1 = l1.observable()
            self.currentPowerL2 = l2.observable()
            self.currentPowerL3 = l3.observable()
        } else {
            self.currentPowerL1 = Characteristic<Float>()
            self.currentPowerL2 = Characteristic<Float>()
            self.currentPowerL3 = Characteristic<Float>()
        }
        
        self.meterType = service.type?.observable() ?? Characteristic<UInt8>()
    }
    
    @ViewBuilder
    var body: some View {
        ElectricityMeterServiceView(name: .constant(service.name),
                                    currentPower: self.$currentPower.value,
                                    currentPowerL1: self.currentPowerL1.present ? self.$currentPowerL1.value : nil,
                                    currentPowerL2: self.currentPowerL2.present ? self.$currentPowerL2.value : nil,
                                    currentPowerL3: self.currentPowerL3.present ? self.$currentPowerL3.value : nil,
                                    type: self.meterType.present && self.meterType.value != nil ? ElectricityMeterTypes(rawValue: self.meterType.value!) ?? .other : .other
        )
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.currentPower.reload()
            self.currentPowerL1.reload()
            self.currentPowerL2.reload()
            self.currentPowerL3.reload()
        }
    }
    
}

struct TotalStorageView: View {
    
    let service: EnergyStorageService
    
    @ObservedObject var batteryLevel: Characteristic<UInt8>
    @ObservedObject var chargingState: Characteristic<UInt8>
    @ObservedObject var statusLowBattery: Characteristic<UInt8>
    @ObservedObject var energyCapacity: Characteristic<Float>
       
    init(_ service: EnergyStorageService) {
        self.service = service
        
        self.batteryLevel = service.batteryLevel.observable()
        
        self.chargingState = service.chargingState.observable()
        
        self.statusLowBattery = service.statusLowBattery.observable()
        
        self.energyCapacity = service.energyCapacity?.observable() ?? Characteristic<Float>()
    }
    
    @ViewBuilder
    var body: some View {
        EnergyStorageServiceView(batteryLevel: self.$batteryLevel.value, chargingState: self.$chargingState.value, statusLowBattery: self.$statusLowBattery.value, energyCapacity: self.energyCapacity.present ? self.$energyCapacity.value : nil)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.batteryLevel.reload()
            self.chargingState.reload()
            self.statusLowBattery.reload()
            self.energyCapacity.reload()
        }
    }
    
}
