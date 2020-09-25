//
//  ChargingStationQuickView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 20.09.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import SwiftUI
import UIKit


struct ChargingStationQuickView: View {
    
    @ObservedObject var accessory: Accessory
    
    @State private var showDetail: Bool = false
    
    private let impact = UIImpactFeedbackGenerator(style: .rigid)
    
    
    init(accessory: Accessory) {
        self.accessory = accessory
    }
    
    @ViewBuilder
    var body: some View {
        WrapperView(edges: .init()) {
            VStack(spacing: 0) {
                if !self.accessory.value.isReachable {
                    ConnectingToAccessoryView(accessory: self.$accessory.value)
                } else {
                    VStack {
                        ElectricVehicleChargingStationServiceView(accessory.value.services.typed().first!)
                        Spacer()
                        HStack(alignment: .bottom) {
                            Text(self.accessory.value.name).font(.footnote).bold().lineLimit(1)
                            Spacer()
                        }
                        HStack {
                            Text(self.accessory.value.room?.name ?? "Default Room").font(.footnote).bold().lineLimit(1).foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
            }
        }
        .onTapGesture {
            self.detail()
        }
        .withAccessoryDetail(accessory: self.accessory, isPresented: self.$showDetail, content: {ChargingStationDetailView(accessory: self.accessory)})
    }
    
    private func detail() {
        self.showDetail = true
        self.impact.impactOccurred()
    }
    
}

