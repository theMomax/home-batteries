//
//  ElectricVehicleChargingStationServiceView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 20.09.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//


import SwiftUI
import HomeKit

struct ElectricVehicleChargingStationServiceView: View {

    let service: ElectricVehicleChargingStationService

    @ObservedObject var active: Characteristic<UInt8>
    @ObservedObject var batteryLevel: Characteristic<UInt8>
    @ObservedObject var chargingState: Characteristic<UInt8>
    @ObservedObject var statusLowBattery: Characteristic<UInt8>
    
    @ObservedObject var estimatedRange: Characteristic<Float>
    @ObservedObject var currentPower: Characteristic<Float>
    
    
    init(_ service: ElectricVehicleChargingStationService) {
        self.service = service
        
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
        ElectricVehicleChargingStationView(active: self.$active.value, batteryLevel: self.$batteryLevel.value, chargingState: self.$chargingState.value, statusLowBattery: self.$statusLowBattery.value, estimatedRange: OptBinding(self.$estimatedRange.value), currentPower: OptBinding(self.$currentPower.value))
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.active.reload()
            self.batteryLevel.reload()
            self.chargingState.reload()
            self.statusLowBattery.reload()
            self.estimatedRange.reload()
            self.currentPower.reload()
        }
    }

}

struct ElectricVehicleChargingStationView: View {
    
    @Binding var active: UInt8?
    @Binding var batteryLevel: UInt8?
    @Binding var chargingState: UInt8?
    @Binding var statusLowBattery: UInt8?
    
    @OptBinding var estimatedRange: Float?
    @OptBinding var currentPower: Float?
    
    var body: some View {
        if self.active == Active.active {
            VStack {
                HStack {
                    if self.chargingState == ChargingState.notChargeable {
                        Text("full").foregroundColor(.green)
                    } else if self.chargingState == ChargingState.charging {
                        Text("charging")
                    } else if statusLowBattery == StatusLowBattery.low {
                        Text("low").foregroundColor(.red)
                    } else {
                        Text("not charging")
                    }
                    Spacer()
                }.lineLimit(1).font(.footnote).foregroundColor(.secondary)
                Spacer()
                HStack {
                    Spacer()
                    self.rangeAndSoC
                }
                Spacer()
            }
        } else {
            VStack(spacing: 5) {
                Spacer()
                Image(systemName: "car").font(.title)
                Text("Car not reachable").font(.caption)
                Spacer()
            }.foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    var rangeAndSoC: some View {
        if self._estimatedRange.present {
            VStack(alignment: .trailing) {
                HStack(spacing: 2) {
                    Text(EstimatedRange.format(self.estimatedRange ?? 0.0)).lineLimit(1).fixedSize()
                    Text(EstimatedRange.unit()!).foregroundColor(.secondary).fixedSize()
                }.font(.title)
                HStack(spacing: 2) {
                    Text(BatteryLevel.format(self.batteryLevel)).lineLimit(1).fixedSize()
                    Text(BatteryLevel.unit()!).fixedSize()
                }.font(.caption).foregroundColor(.secondary)
            }
        } else {
            HStack(spacing: 2) {
                Text(BatteryLevel.format(self.batteryLevel)).font(.title).lineLimit(1).fixedSize()
                Text(BatteryLevel.unit()!).font(Font.system(.title)).foregroundColor(.secondary).fixedSize()
            }
        }
    }
}


struct ElectricVehicleChargingStationServiceView_Previews: PreviewProvider {
        
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach([UInt8(0), 1, nil], id: \.self) { active in
                ForEach([UInt8(0), 1, 2, nil], id: \.self) { chargingState in
                    Self.content(colorScheme, active, chargingState)
                }
            }.environment(\.colorScheme, colorScheme)
        }
    }
    
    private static func content(_ colorScheme: ColorScheme, _ active: UInt8?, _ chargingState: UInt8?) -> some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                HStack {
                    WrapperView {
                        ElectricVehicleChargingStationView(active: .constant(active), batteryLevel: .constant(20), chargingState: .constant(chargingState), statusLowBattery: .constant(StatusLowBattery.low), estimatedRange: nil, currentPower: nil)
                    }
                    WrapperView {
                        ElectricVehicleChargingStationView(active: .constant(active), batteryLevel: .constant(60), chargingState: .constant(chargingState), statusLowBattery: .constant(StatusLowBattery.normal), estimatedRange: .constant(200.0 + (100.0/3.0)), currentPower: nil)
                    }
                }
            }
        }
        .previewDisplayName("\(colorScheme) -> \(Active.format(active)) -> \(ChargingState.format(chargingState))")
    }
}
