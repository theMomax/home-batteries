//
//  MeterServiceView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 01.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI
import HomeKit

enum EnergyMeterType: UInt8 {
    case other = 0
    case production = 1
    case consumption = 2
    case storage = 3
    case grid = 4
}

struct ElectricityMeterServiceView: View {
    
    static let supportedServices = ["00000002-0000-1000-8000-0036AC324978"]
    
    var name: Binding<String?>?
    @Binding var currentPower: Float?
    var currentPowerL1: Binding<Float?>?
    var currentPowerL2: Binding<Float?>?
    var currentPowerL3: Binding<Float?>?
    let type: EnergyMeterType
    
    @ViewBuilder
    var body: some View {
        VStack {
            HStack(spacing: 2) {
                Text(String(format: "%.0f", currentPower ?? 0.0)).font(Font.system(.title)).lineLimit(1)
                Text("W").font(Font.system(.title)).foregroundColor(.secondary)
                
                Spacer()
                
                if self.name != nil {
                    Text(self.name!.wrappedValue ?? "?")
                }
            }
            
            if self.currentPowerL1 != nil && self.currentPowerL2 != nil && self.currentPowerL3 != nil {
                HorizontalBarDiagram([
                    Segment(currentPowerL1!, name: "L1"),
                    Segment(currentPowerL2!, name: "L2"),
                    Segment(currentPowerL3!, name: "L3")
                ],
                positiveColors: self.type == EnergyMeterType.storage || self.type == EnergyMeterType.grid ? HorizontalBarDiagram.negativeColors : HorizontalBarDiagram.positiveColors,
                negativeColors: self.type == EnergyMeterType.storage || self.type == EnergyMeterType.grid ? HorizontalBarDiagram.positiveColors : HorizontalBarDiagram.negativeColors)
            }
        }
    }
}


struct ElectricityMeterServiceView_Previews: PreviewProvider {
        
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach([nil, "Production"], id: \.self) { name in
                ForEach([false, true], id: \.self) { lines in
                    ZStack {
                        Color(.systemBackground).edgesIgnoringSafeArea(.all)
                        
                        
                        ScrollView {
                            AccessoryWrapperView {
                                ElectricityMeterServiceView(
                                    name: name == nil ? nil : .constant(name!),
                                    currentPower: .constant(325.34),
                                    currentPowerL1: lines ? .constant(12.34) : nil,
                                    currentPowerL2: lines ? .constant(203.34) : nil,
                                    currentPowerL3: lines ? .constant(104.34) : nil,
                                    type: .other)
                                    
                            }
                        }
                    }
                }
                
                .previewDisplayName("\(colorScheme) -> name: \(name ?? "nil")")
            }
            .environment(\.colorScheme, colorScheme)
        }
    }
}
