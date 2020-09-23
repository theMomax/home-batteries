//
//  StorageServiceView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 02.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI
import HomeKit

struct EnergyStorageServiceView: View {
    
    @Binding var batteryLevel: UInt8?
    @Binding var chargingState: UInt8?
    @Binding var statusLowBattery: UInt8?
    var energyCapacity: Binding<Float?>?
    
    @ViewBuilder
    var body: some View {
        HStack {
            Spacer().layoutPriority(0)
            BatteryDiagram(batteryLevel: $batteryLevel, chargingState: $chargingState, statusLowBattery: $statusLowBattery)
            .layoutPriority(0)
            
            VStack(alignment: .leading) {
                Text(String(format: "%d %%", batteryLevel ?? 0)).font(Font.system(.largeTitle))
                
                if energyCapacity != nil {
                    Text(String(format: "of %.1f kWh", energyCapacity!.wrappedValue ?? 0.0)).font(Font.system(.footnote)).foregroundColor(.secondary)
                }
            }.padding(.horizontal).layoutPriority(1)
            Spacer().layoutPriority(0)
        }
    }
}

struct EnergyStorageServiceQuickView: View {
    
    @Binding var batteryLevel: UInt8?
    @Binding var chargingState: UInt8?
    @Binding var statusLowBattery: UInt8?
    
    @ViewBuilder
    var body: some View {
        HStack {
            BatteryDiagram(batteryLevel: $batteryLevel, chargingState: $chargingState, statusLowBattery: $statusLowBattery)
            .layoutPriority(0)
        }
    }
}


struct EnergyStorageServiceView_Previews: PreviewProvider {
        
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { (colorScheme: ColorScheme) in
            ForEach([0,20,80,100], id: \.self) { (batteryLevel: Int) in
                ForEach([0, 1], id: \.self) { (chargingState: Int) in
                    ZStack {
                        Color(.systemBackground).edgesIgnoringSafeArea(.all)

                        ScrollView {
                            WrapperView {
                                EnergyStorageServiceView(
                                    batteryLevel: .constant(UInt8(batteryLevel)),
                                    chargingState: .constant(UInt8(chargingState)),
                                    statusLowBattery: .constant(UInt8(batteryLevel <= 20 ? 1 : 0)),
                                    energyCapacity: .constant(12.0)
                                )
                            }
                            HStack {
                                WrapperView {
                                    EnergyStorageServiceQuickView(
                                        batteryLevel: .constant(UInt8(batteryLevel)),
                                        chargingState: .constant(UInt8(chargingState)),
                                        statusLowBattery: .constant(UInt8(batteryLevel <= 20 ? 1 : 0))
                                    )
                                }
                                WrapperView(edges: .init(arrayLiteral: .trailing, .vertical)) {
                                    EnergyStorageServiceQuickView(
                                        batteryLevel: .constant(UInt8(batteryLevel)),
                                        chargingState: .constant(UInt8(chargingState)),
                                        statusLowBattery: .constant(UInt8(batteryLevel <= 20 ? 1 : 0))
                                    )
                                }
                            }
                        }
                    }
                    .previewDisplayName("\(colorScheme) -> \(UInt8(batteryLevel)); \(chargingState)")
                }
            }
            .environment(\.colorScheme, colorScheme)
        }
    }
}
