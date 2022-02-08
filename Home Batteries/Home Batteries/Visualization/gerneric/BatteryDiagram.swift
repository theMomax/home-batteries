//
//  BatteryDiagram.swift
//  Home Batteries
//
//  Created by Max Obermeier on 03.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI
import BatteryView

struct BatteryDiagram: View {
    @Binding var batteryLevel: UInt8?
    @Binding var chargingState: UInt8?
    @Binding var statusLowBattery: UInt8?

    @ViewBuilder
    var body: some View {
        Battery(Binding(get: {
            if let level = self.batteryLevel {
                return Float(level) / 100.0
            }
            return 0.0
        }, set: { _ in }), Binding(get: {
            guard let state = self.chargingState else {
                return .unknown
            }
            switch state {
            case ChargingState.charging:
                return .charging
            case ChargingState.notCharging:
                return .unplugged
            case ChargingState.notChargeable:
                return .full
            default:
                return .unknown
            }
        }, set: { _ in }), .constant(.normal))
        .batteryStyle(SFSymbolStyle(animation: nil))
    }
    
    private var warningLevel: Float {
        if let statuslow = statusLowBattery {
            if statuslow == StatusLowBattery.low {
                return 1.0
            } else if statuslow == StatusLowBattery.normal {
                return 0.0
            }
        }
        return 0.2
    }
}
