//
//  OutletQuickView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 28.06.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import SwiftUI
import UIKit


struct OutletQuickView: View {
    
    @ObservedObject var accessory: Accessory
    @ObservedObject var on: Characteristic<Bool>
    
    init(accessory: Accessory) {
        self.accessory = accessory
        let primary: OutletService = accessory.value.services.typed().first!
        self.on = primary.on.observable()
    }
    
    @ViewBuilder
    var body: some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .rigid)
            if let o = self.on.value {
                self.on.characteristic!.writeValue(!o, completionHandler: { err in
                    if err == nil {
                        self.on.value = !o
                    }
                })
                impactMed.impactOccurred()
            }
        }, label: {
            WrapperView(edges: .init()) {
                VStack(spacing: 0) {
                    if !self.accessory.value.isReachable {
                        ConnectingToAccessoryView(accessory: self.$accessory.value)
                    } else {
                        VStack {
                            OutletServiceView(self.accessory.value.services.typed().first!)
                            Spacer()
                            HStack(alignment: .center) {
                                Spacer()
                                self.metersView(self.accessory.value.services.typed())
                            }
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
            }.foregroundColor(.primary)
        })
    }
    
    @ViewBuilder
    private func metersView(_ meters: [ElectricityMeterService]) -> some View {
        if meters.count == 1 {
            MeterQuickView(meters[0], if: {_ in true})
        }
        ForEach(0..<meters.count) { index in
            MeterQuickView(meters[index])
        }
    }
}
