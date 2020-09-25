//
//  HomeBatteryAccessoryQuickView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 21.06.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import SwiftUI
import UIKit


struct HomeBatteryAccessoryQickView: View {
    
    @ObservedObject var accessory: Accessory
    
    @State private var showDetail: Bool = false
    
    private let impact = UIImpactFeedbackGenerator(style: .rigid)
    
    @ViewBuilder
    var body: some View {
        WrapperView(edges: .init()) {
            VStack(spacing: 0) {
                if !self.accessory.value.isReachable {
                    ConnectingToAccessoryView(accessory: self.$accessory.value)
                } else {
                    VStack {
                        HStack(alignment: .top) {
                            if self.hasEnergyStorage() {
                                TotalStorageQuickView(self.accessory.value.services.typed().first!)
                            } else {
                                self.iconView(self.accessory.value.services.typed())
                            }
                            Spacer()
                            if self.hasState() {
                                TotalStateView(self.accessory.value.services.typed().first!)
                            }
                        }
                        Spacer()
                        HStack(alignment: .center) {
                            Spacer()
                            self.metersView(self.accessory.value.services.typed())
                        }
                        Spacer()
                        HStack(alignment: .bottom) {
                            Text(self.accessory.value.name).font(.footnote).bold().lineLimit(1)
                            Spacer()
                        }
                        HStack {
                            Text(self.accessory.value.room?.name ?? "Default Room").font(.footnote).bold().lineLimit(1).foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
            }
        }
        .onTapGesture {
            self.detail()
        }
        .withAccessoryDetail(accessory: self.accessory, isPresented: self.$showDetail, content: {
            HomeBatteryAccessoryDetailLayoutView(accessory: self.accessory)
        })
    }
    
    private func detail() {
        self.showDetail = true
        self.impact.impactOccurred()
    }
    
    @ViewBuilder
    private func metersView(_ meters: [ElectricityMeterService]) -> some View {
        if meters.count == 1 {
            MeterQuickView(meters[0], if: {_ in true})
        }
        ForEach(0..<meters.count) { index in
            MeterQuickView(meters[index])
        }
    }
    
    @ViewBuilder
    private func iconView(_ meters: [ElectricityMeterService]) -> some View {
        if meters.count == 1 {
            MeterIconView(meters[0], if: {_ in true})
        }
        ForEach(0..<meters.count) { index in
            MeterIconView(meters[index])
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
}

struct MeterQuickView: View {
    
    @ObservedObject var meterType: Characteristic<UInt8>
    @ObservedObject var currentPower: Characteristic<Float>
    
    let service: ElectricityMeterService
    
    let condition: (ElectricityMeterTypes?) -> Bool
    
    init(_ service: ElectricityMeterService, if condition: @escaping (ElectricityMeterTypes?) -> Bool = { t in t == .excess }) {
        self.service = service
        self.condition = condition
        
        self.currentPower = service.power.observable()
        self.meterType = service.type?.observable(updating: false) ?? Characteristic<UInt8>()
    }
    
    @ViewBuilder
    var body: some View {
        if condition(meterType.value == nil ? nil : ElectricityMeterTypes.init(rawValue: meterType.value!)) {
            ElectricityMeterServiceQuickView(
                                        currentPower: self.$currentPower.value,
                                        type: self.meterType.present && self.meterType.value != nil ? ElectricityMeterTypes(rawValue: self.meterType.value!) ?? .other : .other
            )
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.reload()
            }

        } else {
            EmptyView()
        }
    }
    
    func reload() {
        self.currentPower.reload()
        self.meterType.reload()
    }
}

struct MeterIconView: View {
    
    @ObservedObject var meterType: Characteristic<UInt8>
    
    let service: ElectricityMeterService
    
    let condition: (ElectricityMeterTypes?) -> Bool
    
    init(_ service: ElectricityMeterService, if condition: @escaping (ElectricityMeterTypes?) -> Bool = { t in t == .excess }) {
        self.service = service
        self.condition = condition
        
        self.meterType = service.type?.observable(updating: false) ?? Characteristic<UInt8>()
    }
    
    @ViewBuilder
    var body: some View {
        if condition(meterType.value == nil ? nil : ElectricityMeterTypes.init(rawValue: meterType.value!)) {
            self.icon().font(.title)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.reload()
            }

        } else {
            EmptyView()
        }
    }
    
    func reload() {
        self.meterType.reload()
    }
    
    
    private func icon() -> some View {
        if let t = self.meterType.value {
            switch ElectricityMeterTypes.init(rawValue: t) ?? .other {
            case .consumption:
                return Image(systemName: "house").foregroundColor(.red)
            case .grid:
                return Image(systemName: "arrow.merge").foregroundColor(.blue)
            case .production:
                return Image(systemName: "sun.max.fill").foregroundColor(.yellow)
            case .storage:
                return Image(systemName: "battery.100").foregroundColor(.primary)
            case .excess:
                return Image(systemName: "bolt.horizontal").foregroundColor(.blue)
            default:
                return Image(systemName: "questionmark.circle").foregroundColor(.secondary)
            }
        } else {
            return Image(systemName: "questionmark.circle").foregroundColor(.secondary)
        }
    }
}

struct TotalStorageQuickView: View {
    
    let service: EnergyStorageService
    
    @ObservedObject var batteryLevel: Characteristic<UInt8>
    @ObservedObject var chargingState: Characteristic<UInt8>
    @ObservedObject var statusLowBattery: Characteristic<UInt8>
       
    init(_ service: EnergyStorageService) {
        self.service = service
        
        self.batteryLevel = service.batteryLevel.observable()
        
        self.chargingState = service.chargingState.observable()
        
        self.statusLowBattery = service.statusLowBattery.observable()
    }
    
    @ViewBuilder
    var body: some View {
        EnergyStorageServiceQuickView(batteryLevel: self.$batteryLevel.value, chargingState: self.$chargingState.value, statusLowBattery: self.$statusLowBattery.value)
        .frame(height: 25)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.reload()
        }
    }
    
    func reload() {
        self.batteryLevel.reload()
        self.chargingState.reload()
        self.statusLowBattery.reload()
    }
    
}
