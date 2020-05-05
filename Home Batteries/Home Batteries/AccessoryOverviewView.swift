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
    
    static let supportedServices = ["00000001-0000-1000-8000-0036AC324978", "00000002-0000-1000-8000-0036AC324978", "00000003-0000-1000-8000-0036AC324978"]
    
    @ObservedObject var accessory: Accessory
    
   
    @ViewBuilder
    var body: some View {
        AccessoryWrapperView {
            if !self.accessory.value.isReachable {
                ConnectingToAccessoryView(accessory: self.accessory)
            } else {
                VStack {
                    HStack {
                        Text(self.accessory.value.name)
                        if self.hasState() {
                            TotalStateView(self.accessory)
                        }
                    }
                    if self.hasEnergyStorage() {
                        TotalStorageView(self.accessory).padding(.bottom)
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
                characteristic.characteristicType == "00000002-0001-1000-8000-0036AC324978"
            })
            && service.characteristics.contains(where: { characteristic in
                characteristic.characteristicType == "00000003-0001-1000-8000-0036AC324978"
            })
            && service.characteristics.contains(where: { characteristic in
                characteristic.characteristicType == "00000004-0001-1000-8000-0036AC324978"
            })
        })
    }
    
    private func metersWithoutAllLines() -> [HMService] {
        return self.accessory.value.services.filter({service in
            MeterView.supportedServices.contains(service.serviceType)
            && (!service.characteristics.contains(where: { characteristic in
                characteristic.characteristicType == "00000002-0001-1000-8000-0036AC324978"
            })
            || !service.characteristics.contains(where: { characteristic in
                characteristic.characteristicType == "00000003-0001-1000-8000-0036AC324978"
            })
            || !service.characteristics.contains(where: { characteristic in
                characteristic.characteristicType == "00000004-0001-1000-8000-0036AC324978"
            }))
        })
    }
    
}

struct TotalStateView: View {
    
    static let supportedServices = ["00000001-0000-1000-8000-0036AC324978"]
    
    @ObservedObject var accessory: Accessory
    
    @ObservedObject var totalState: Characteristic<UInt8>
       
    init(_ accessory: Accessory) {
        self.accessory = accessory
       
        self.totalState = Characteristic<UInt8>(accessory.value.services.filter({service in TotalStateView.supportedServices.contains(service.serviceType)})
       .first!.characteristics.filter({characteristic in
           characteristic.characteristicType == "00000077-0000-1000-8000-0026BB765291"
       }).first!, updating: true)
    }
    
    @ViewBuilder
    var body: some View {
        ControllerServiceView(state: self.$totalState.value)
    }
    
}

struct MeterView: View {
    
    static let supportedServices = ElectricityMeterServiceView.supportedServices
    
    let service: HMService
    
    @ObservedObject var currentPower: Characteristic<Float>
    let currentPowerL1: ObservedObject<Characteristic<Float>>?
    let currentPowerL2: ObservedObject<Characteristic<Float>>?
    let currentPowerL3: ObservedObject<Characteristic<Float>>?
       
    init(_ service: HMService) {
        self.service = service

        self.currentPower = Characteristic<Float>(self.service.characteristics.filter({characteristic in
           characteristic.characteristicType == "00000001-0001-1000-8000-0036AC324978"
        }).first!, updating: true)
        
        if let c = self.service.characteristics.filter({characteristic in
           characteristic.characteristicType == "00000002-0001-1000-8000-0036AC324978"
        }).first {
            self.currentPowerL1 = ObservedObject.init(wrappedValue: Characteristic<Float>(c, updating: true))
        } else {
            self.currentPowerL1 = nil
        }
        
        if let c = self.service.characteristics.filter({characteristic in
           characteristic.characteristicType == "00000003-0001-1000-8000-0036AC324978"
        }).first {
            self.currentPowerL2 = ObservedObject.init(wrappedValue: Characteristic<Float>(c, updating: true))
        } else {
            self.currentPowerL2 = nil
        }
        
        if let c = self.service.characteristics.filter({characteristic in
           characteristic.characteristicType == "00000004-0001-1000-8000-0036AC324978"
        }).first {
            self.currentPowerL3 = ObservedObject.init(wrappedValue: Characteristic<Float>(c, updating: true))
        } else {
            self.currentPowerL3 = nil
        }
    }
    
    @ViewBuilder
    var body: some View {
        ElectricityMeterServiceView(name: .constant(service.name),
                                    currentPower: self.$currentPower.value,
                                    currentPowerL1: self.currentPowerL1?.projectedValue.value,
                                    currentPowerL2: self.currentPowerL2?.projectedValue.value,
                                    currentPowerL3: self.currentPowerL3?.projectedValue.value
        )
    }
    
}

struct TotalStorageView: View {
    
    static let supportedServices = EnergyStorageServiceView.supportedServices
    
    @ObservedObject var accessory: Accessory
    
    @ObservedObject var batteryLevel: Characteristic<UInt8>
    @ObservedObject var chargingState: Characteristic<UInt8>
    @ObservedObject var statusLowBattery: Characteristic<UInt8>
    let energyCapacity: ObservedObject<Characteristic<Float>>?
       
    init(_ accessory: Accessory) {
        self.accessory = accessory
        
        self.batteryLevel = Characteristic<UInt8>(accessory.value.services.filter({service in TotalStorageView.supportedServices.contains(service.serviceType)})
        .first!.characteristics.filter({characteristic in
            characteristic.characteristicType == "00000068-0000-1000-8000-0026BB765291"
        }).first!, updating: true)
        
        self.chargingState = Characteristic<UInt8>(accessory.value.services.filter({service in TotalStorageView.supportedServices.contains(service.serviceType)})
        .first!.characteristics.filter({characteristic in
            characteristic.characteristicType == "0000008F-0000-1000-8000-0026BB765291"
        }).first!, updating: true)
        
        self.statusLowBattery = Characteristic<UInt8>(accessory.value.services.filter({service in TotalStorageView.supportedServices.contains(service.serviceType)})
        .first!.characteristics.filter({characteristic in
            characteristic.characteristicType == "00000079-0000-1000-8000-0026BB765291"
        }).first!, updating: true)
        
        if let c = accessory.value.services.filter({service in TotalStorageView.supportedServices.contains(service.serviceType)})
        .first?.characteristics.filter({characteristic in
            characteristic.characteristicType == "00000005-0001-1000-8000-0036AC324978"
        }).first {
            self.energyCapacity = ObservedObject.init(wrappedValue: Characteristic<Float>(c, updating: true))
        } else {
            self.energyCapacity = nil
        }
    }
    
    @ViewBuilder
    var body: some View {
        EnergyStorageServiceView(batteryLevel: self.$batteryLevel.value, chargingState: self.$chargingState.value, statusLowBattery: self.$statusLowBattery.value, energyCapacity: self.energyCapacity?.projectedValue.value)
    }
    
}
