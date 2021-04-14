//
//  MeterServiceQuickView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 17.10.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

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
    let type: ElectricityMeterTypes?
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: -5) {
            HStack(spacing: 2) {
                Spacer()
                Text(String(format: "%.0f", abs(currentPower ?? 1000)))
                    .asPlaceholder(nil: currentPower)
                    .font(Font.system(.title)).lineLimit(1).foregroundColor((self.type ?? .other).color(for: currentPower)).fixedSize()
                
                Text("W").font(Font.system(.title)).foregroundColor(.secondary).fixedSize()
            }
            
            HStack {
                Spacer()
                Text(self.type?.description(for: currentPower ?? 0.0) ?? "unknown")
                    .asPlaceholder(nil: type)
                    .font(.footnote).foregroundColor(.secondary)
            }
        }
    }
}

