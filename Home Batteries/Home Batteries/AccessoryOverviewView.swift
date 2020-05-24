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

struct AccessoryOverviewView: View {
    
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
                            TotalStateView(self.$accessory.value)
                        }
                    }
                    if self.hasEnergyStorage() {
                        TotalStorageView(self.$accessory.value).padding(.bottom)
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
        return !accessory.value.services.filter({service in TotalStateView.supportedServices.contains(service.serviceType)}).isEmpty
    }
    
    private func hasEnergyStorage() -> Bool {
        return !accessory.value.services.filter({service in TotalStorageView.supportedServices.contains(service.serviceType)}).isEmpty
    }
    
    private func metersWithAllLines() -> [HMService] {
        return self.accessory.value.services.filter({service in
            MeterView.supportedServices.contains(service.serviceType)
            && service.characteristics.contains(where: { characteristic in
                characteristic.characteristicType == CurrentPowerL1.uuid
            })
            && service.characteristics.contains(where: { characteristic in
                characteristic.characteristicType == CurrentPowerL2.uuid
            })
            && service.characteristics.contains(where: { characteristic in
                characteristic.characteristicType == CurrentPowerL3.uuid
            })
        })
    }
    
    private func metersWithoutAllLines() -> [HMService] {
        return self.accessory.value.services.filter({service in
            MeterView.supportedServices.contains(service.serviceType)
            && (!service.characteristics.contains(where: { characteristic in
                characteristic.characteristicType == CurrentPowerL1.uuid
            })
            || !service.characteristics.contains(where: { characteristic in
                characteristic.characteristicType == CurrentPowerL2.uuid
            })
            || !service.characteristics.contains(where: { characteristic in
                characteristic.characteristicType == CurrentPowerL3.uuid
            }))
        })
    }
    
}

struct TotalStateView: View {
    
    static let supportedServices = [ControllerService.uuid]
    
    @Binding var accessory: HMAccessory
    
    @ObservedObject var totalState: Characteristic<UInt8>
       
    init(_ accessory: Binding<HMAccessory>) {
        self._accessory = accessory
       
        self.totalState = Characteristic<UInt8>(accessory.wrappedValue.services.filter({service in TotalStateView.supportedServices.contains(service.serviceType)})
       .first!.characteristics.filter({characteristic in
        characteristic.characteristicType == StatusFault.uuid
       }).first!, updating: true)
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
    
    static let supportedServices = ElectricityMeterServiceView.supportedServices
    
    let service: HMService
    
    @ObservedObject var currentPower: Characteristic<Float>
    @ObservedObject var currentPowerL1: Characteristic<Float>
    @ObservedObject var currentPowerL2: Characteristic<Float>
    @ObservedObject var currentPowerL3: Characteristic<Float>
    @ObservedObject var meterType: Characteristic<UInt8>
       
    init(_ service: HMService) {
        self.service = service

        self.currentPower = Characteristic<Float>(self.service.characteristics.filter({characteristic in
            characteristic.characteristicType == CurrentPower.uuid
        }).first!, updating: true)
        
        if let c = self.service.characteristics.filter({characteristic in
            characteristic.characteristicType == CurrentPowerL1.uuid
        }).first {
            self.currentPowerL1 = Characteristic<Float>(c, updating: true)
        } else {
            self.currentPowerL1 = Characteristic<Float>()
        }
        
        if let c = self.service.characteristics.filter({characteristic in
            characteristic.characteristicType == CurrentPowerL2.uuid
        }).first {
            self.currentPowerL2 = Characteristic<Float>(c, updating: true)
        } else {
            self.currentPowerL2 = Characteristic<Float>()
        }
        
        if let c = self.service.characteristics.filter({characteristic in
            characteristic.characteristicType == CurrentPowerL3.uuid
        }).first {
            self.currentPowerL3 = Characteristic<Float>(c, updating: true)
        } else {
            self.currentPowerL3 = Characteristic<Float>()
        }
        
        if let c = self.service.characteristics.filter({characteristic in
            characteristic.characteristicType == ElectricityMeterType.uuid
        }).first {
            self.meterType = Characteristic<UInt8>(c, updating: false)
        } else {
            self.meterType = Characteristic<UInt8>()
        }
    }
    
    @ViewBuilder
    var body: some View {
        ElectricityMeterServiceView(name: .constant(service.name),
                                    currentPower: self.$currentPower.value,
                                    currentPowerL1: self.currentPowerL1.present ? self.$currentPowerL1.value : nil,
                                    currentPowerL2: self.currentPowerL2.present ? self.$currentPowerL2.value : nil,
                                    currentPowerL3: self.currentPowerL3.present ? self.$currentPowerL3.value : nil,
                                    type: self.meterType.present && self.meterType.value != nil ? EnergyMeterType(rawValue: self.meterType.value!) ?? .other : .other
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
    
    static let supportedServices = EnergyStorageServiceView.supportedServices
    
    @Binding var accessory: HMAccessory
    
    @ObservedObject var batteryLevel: Characteristic<UInt8>
    @ObservedObject var chargingState: Characteristic<UInt8>
    @ObservedObject var statusLowBattery: Characteristic<UInt8>
    @ObservedObject var energyCapacity: Characteristic<Float>
       
    init(_ accessory: Binding<HMAccessory>) {
        self._accessory = accessory
        
        self.batteryLevel = Characteristic<UInt8>(accessory.wrappedValue.services.filter({service in TotalStorageView.supportedServices.contains(service.serviceType)})
        .first!.characteristics.filter({characteristic in
            characteristic.characteristicType == "00000068-0000-1000-8000-0026BB765291"
        }).first!, updating: true)
        
        self.chargingState = Characteristic<UInt8>(accessory.wrappedValue.services.filter({service in TotalStorageView.supportedServices.contains(service.serviceType)})
        .first!.characteristics.filter({characteristic in
            characteristic.characteristicType == "0000008F-0000-1000-8000-0026BB765291"
        }).first!, updating: true)
        
        self.statusLowBattery = Characteristic<UInt8>(accessory.wrappedValue.services.filter({service in TotalStorageView.supportedServices.contains(service.serviceType)})
        .first!.characteristics.filter({characteristic in
            characteristic.characteristicType == "00000079-0000-1000-8000-0026BB765291"
        }).first!, updating: true)
        
        if let c = accessory.wrappedValue.services.filter({service in TotalStorageView.supportedServices.contains(service.serviceType)})
        .first?.characteristics.filter({characteristic in
            characteristic.characteristicType == "00000005-0001-1000-8000-0036AC324978"
        }).first {
            self.energyCapacity = Characteristic<Float>(c)
        } else {
            self.energyCapacity = Characteristic<Float>()
        }
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
