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

struct HomeBatteryAccessoryDetailView: View {
    
    @ObservedObject var accessory: Accessory
    
    init(accessory: Accessory) {
        self.accessory = accessory
    }
    
    @ViewBuilder
    var body: some View {
        VStack {
            if self.hasEnergyStorage() {
                TotalStorageView(self.accessory.value.services.typed().first!).padding(.bottom)
            }
            MeterAccessoryLiveView(self.accessory)
        }
    }
    
    private func hasEnergyStorage() -> Bool {
        let es: [EnergyStorageService] = self.accessory.value.services.typed()
        return !es.isEmpty
    }
}

struct MeterAccessoryLiveView: View {
    private let meters: [ElectricityMeterService]
    
    @State private var showExtendedViewFor: Int? = 0
    
    init(_ accessory: Accessory) {
        self.meters = Self.metersWithAllLines(accessory) + Self.metersWithoutAllLines(accessory)
    }
    
    @ViewBuilder
    var body: some View {
        ForEach(0..<meters.count) { index in
            MeterView(self.meters[index], extended: Binding(get: {
                return self.showExtendedViewFor == index
            }, set: { isExtended in
                if isExtended {
                    self.showExtendedViewFor = index
                } else {
                    self.showExtendedViewFor = nil
                }
            })).padding(.top)
        }
    }
    
    
    private static func metersWithAllLines(_ accessory: Accessory) -> [ElectricityMeterService] {
        return accessory.value.services.typed().filter({s in s.lines != nil})
    }
    
    private static func metersWithoutAllLines(_ accessory: Accessory) -> [ElectricityMeterService] {
        return accessory.value.services.typed().filter({s in s.lines == nil})
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
    @Binding var showLines: Bool
       
    init(_ service: ElectricityMeterService, extended showLines: Binding<Bool>) {
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
        
        self.meterType = service.type?.observable(updating: false) ?? Characteristic<UInt8>()
        
        self._showLines = showLines
    }
    
    @ViewBuilder
    var body: some View {
        ElectricityMeterServiceView(name: .constant(service.name),
                                    currentPower: self.$currentPower.value,
                                    currentPowerL1: self.currentPowerL1.present ? self.$currentPowerL1.value : nil,
                                    currentPowerL2: self.currentPowerL2.present ? self.$currentPowerL2.value : nil,
                                    currentPowerL3: self.currentPowerL3.present ? self.$currentPowerL3.value : nil,
                                    type: self.meterType.present && self.meterType.value != nil ? ElectricityMeterTypes(rawValue: self.meterType.value!) ?? .other : .other,
                                    showLines: self.$showLines
        )
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.reload()
        }
    }
    
    func reload() {
        self.currentPower.reload()
        self.currentPowerL1.reload()
        self.currentPowerL2.reload()
        self.currentPowerL3.reload()
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
        
        self.energyCapacity = service.energyCapacity?.observable(updating: false) ?? Characteristic<Float>()
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
