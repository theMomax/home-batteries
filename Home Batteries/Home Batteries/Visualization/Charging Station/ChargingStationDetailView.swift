//
//  ChargingStationDetailView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 24.09.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import SwiftUI

struct ChargingStationDetailView: View {
    
    @ObservedObject var accessory: Accessory
    
    @ObservedObject var active: Characteristic<UInt8>
    @ObservedObject var batteryLevel: Characteristic<UInt8>
    @ObservedObject var chargingState: Characteristic<UInt8>
    @ObservedObject var statusLowBattery: Characteristic<UInt8>
    
    @ObservedObject var estimatedRange: Characteristic<Float>
    @ObservedObject var currentPower: Characteristic<Float>
    
    init(accessory: Accessory) {
        self.accessory = accessory
        
        let service: ElectricVehicleChargingStationService = accessory.value.services.typed().first!
        
        self.active = service.active.observable()
        self.batteryLevel = service.batteryLevel.observable()
        self.chargingState = service.chargingState.observable()
        self.statusLowBattery = service.statusLowBattery.observable()
        
        if let er = service.estimatedRange {
            self.estimatedRange = er.observable()
        } else {
            self.estimatedRange = Characteristic<Float>()
        }
        
        if let cp = service.currentPower {
            self.currentPower = cp.observable()
        } else {
            self.currentPower = Characteristic<Float>()
        }
    }
    
    @ViewBuilder
    var body: some View {
        VStack {
            CharacteristicElementView(self.active)
            
            WrapperView(innerEdges: .init(arrayLiteral: .leading, .vertical), style: .outset) {
                VStack {
                    
                    if self.estimatedRange.present {
                        CharacteristicListElementView(self.estimatedRange)
                        Divider()
                    }
                    CharacteristicListElementView(self.batteryLevel)
                    Divider()
                    CharacteristicListElementView(self.chargingState)
                    Divider()
                    CharacteristicListElementView(self.statusLowBattery)
                    if self.currentPower.present {
                        Divider()
                        CharacteristicListElementView(self.currentPower)
                    }
                }
            }
        }
    }
    
}
