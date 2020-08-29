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

enum ElectricityMeterTypes: UInt8 {
    case other = 0
    case production = 1
    case consumption = 2
    case storage = 3
    case grid = 4
    case excess = 5
}

extension ElectricityMeterTypes: CustomStringConvertible {
    var description: String {
        switch self {
        case .other:
            return "unknown"
        case .production:
            return "production"
        case .consumption:
            return "consumption"
        case .storage:
            return "charge"
        case .grid:
            return "sell"
        case .excess:
            return "excess"
        }
    }
    
    var negativeDescription: String {
        switch self {
        case .other:
            return "unknown"
        case .production:
            return "unknown"
        case .consumption:
            return "unknown"
        case .storage:
            return "discharge"
        case .grid:
            return "buy"
        case .excess:
            return "shortage"
        }
    }
    
    func description(for value: Float) -> String {
        if !self.invertedConnotation {
            if value < 0 {
                return self.negativeDescription
            } else {
                return self.description
            }
        } else {
            if value > 0 {
                return self.negativeDescription
            } else {
                return self.description
            }
        }
    }
}

extension ElectricityMeterTypes {
    var invertedConnotation: Bool {
        return self == ElectricityMeterTypes.storage || self == ElectricityMeterTypes.grid
    }
}

extension ElectricityMeterTypes {
    func color(for currentPower: Float?) -> Color {
        if let p = currentPower {
            if !self.invertedConnotation {
                if p < 0 {
                    return .red
                } else {
                    return .primary
                }
            } else {
                if p > 0 {
                    return .red
                } else {
                    return .primary
                }
            }
        } else {
            return .secondary
        }
    }
}

struct ElectricityMeterServiceQuickView: View {
    
    @Binding var currentPower: Float?
    let type: ElectricityMeterTypes
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: -5) {
            HStack(spacing: 2) {
                Spacer()
                Text(String(format: "%.0f", abs(currentPower ?? 0.0))).font(Font.system(.title)).lineLimit(1).foregroundColor(self.type.color(for: currentPower)).fixedSize()
                Text("W").font(Font.system(.title)).foregroundColor(.secondary).fixedSize()
            }
            if self.type != .other {
                HStack {
                    Spacer()
                    Text(self.type.description(for: currentPower ?? 0.0)).font(.footnote).foregroundColor(.secondary)
                }
            }
        }
    }
}

struct ElectricityMeterServiceView: View {
    
    var name: Binding<String?>?
    @Binding var currentPower: Float?
    var currentPowerL1: Binding<Float?>?
    var currentPowerL2: Binding<Float?>?
    var currentPowerL3: Binding<Float?>?
    let type: ElectricityMeterTypes
    
    @Binding var showLines: Bool
    
    @ViewBuilder
    var body: some View {
        VStack {
            HStack(spacing: 2) {
                if self.name != nil {
                    Text(self.name!.wrappedValue ?? "?").font(.headline)
                }
                
                Spacer()
                
                Text(String(format: "%.0f", abs(currentPower ?? 0.0))).font(.title).lineLimit(1).foregroundColor(self.type.color(for: currentPower)).fixedSize()
                Text("W").font(Font.system(.title)).foregroundColor(.secondary).fixedSize()
            }
            
            if self.showLines && self.currentPowerL1 != nil && self.currentPowerL2 != nil && self.currentPowerL3 != nil {
                HorizontalBarDiagram([
                    Segment(currentPowerL1!, name: "L1"),
                    Segment(currentPowerL2!, name: "L2"),
                    Segment(currentPowerL3!, name: "L3")
                ],
                                     positiveColors: self.type.invertedConnotation ? HorizontalBarDiagram.negativeColors : HorizontalBarDiagram.positiveColors,
                                     negativeColors: self.type.invertedConnotation ? HorizontalBarDiagram.positiveColors : HorizontalBarDiagram.negativeColors)
            }
        }.onTapGesture {
            withAnimation {
                self.showLines.toggle()
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
                            WrapperView {
                                ElectricityMeterServiceView(
                                    name: name == nil ? nil : .constant(name!),
                                    currentPower: .constant(325.34),
                                    currentPowerL1: lines ? .constant(12.34) : nil,
                                    currentPowerL2: lines ? .constant(203.34) : nil,
                                    currentPowerL3: lines ? .constant(104.34) : nil,
                                    type: .other, showLines: .constant(true))
                                    
                            }
                            HStack {
                                WrapperView {
                                    ElectricityMeterServiceQuickView(
                                        currentPower: .constant(325.34),
                                        type: .excess)
                                        
                                }
                                WrapperView(edges: .init(arrayLiteral: .trailing, .vertical)) {
                                    ElectricityMeterServiceQuickView(
                                        currentPower: .constant(-325.34),
                                        type: .excess)
                                        
                                }
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
