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

struct ElectricityMeterServiceView: View {
    
    @OptBinding var name: String?
    @Binding var currentPower: Float?
    @OptBinding var currentPowerL1: Float?
    @OptBinding var currentPowerL2: Float?
    @OptBinding var currentPowerL3: Float?
    let type: ElectricityMeterTypes
    
    @Binding var showLines: Bool
    
    @ViewBuilder
    var body: some View {
        VStack {
            HStack(spacing: 2) {
                VStack {
                    if self._name.present {
                        HStack {
                            if self.name != nil {
                                Text(self.name!).font(.headline)
                            } else {
                                Text("Meter Name").font(.headline).redacted(reason: .placeholder)
                            }
                            
                            Spacer()
                        }
                    }
                    if self.type != .other {
                        HStack {
                            Text(self.type.description(for: self.currentPower ?? 0)).foregroundColor(.secondary).font(.caption)
                            Spacer()
                        }
                    }
                }
                
                Spacer()
                Group {
                    if currentPower != nil {
                        Text(String(format: "%.0f", abs(currentPower!)))
                    } else {
                        Text("1000").redacted(reason: .placeholder)
                    }
                }
                .font(.title).lineLimit(1).foregroundColor(self.type.color(for: currentPower)).fixedSize()
                Text("W").font(Font.system(.title)).foregroundColor(.secondary).fixedSize()
            }
            
            if self.showLines && self.currentPowerL1 != nil && self.currentPowerL2 != nil && self.currentPowerL3 != nil {
                HorizontalBarDiagram([
                    Segment($currentPowerL1, name: "L1"),
                    Segment($currentPowerL2, name: "L2"),
                    Segment($currentPowerL3, name: "L3")
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
            ForEach([nil, Optional<String?>.some("Production"), Optional<String?>.some(nil)], id: \.self) { name in
                ForEach([false, true], id: \.self) { lines in
                    ZStack {
                        Color(.systemBackground).edgesIgnoringSafeArea(.all)
                        
                        
                        ScrollView {
                            WrapperView {
                                ElectricityMeterServiceView(
                                    name: name == nil ? nil : OptBinding(.constant(name!)),
                                    currentPower: .constant(325.34),
                                    currentPowerL1: lines ? OptBinding(.constant(12.34)) : nil,
                                    currentPowerL2: lines ? OptBinding(.constant(203.34)) : nil,
                                    currentPowerL3: lines ? OptBinding(.constant(104.34)) : nil,
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
                
                .previewDisplayName("\(colorScheme) -> name: \(String(describing: name ?? "nil"))")
            }
            .environment(\.colorScheme, colorScheme)
        }
    }
}
