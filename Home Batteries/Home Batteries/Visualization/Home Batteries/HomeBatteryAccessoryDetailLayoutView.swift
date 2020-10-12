//
//  HomeBatteryAccessoryDetailLayoutView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 25.09.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import SwiftUI

struct HomeBatteryAccessoryDetailLayoutView: View {
    
    @ObservedObject var accessory: Accessory
    
    private let controller: ControllerService?
    
    init(accessory: Accessory) {
        self.accessory = accessory
        self.controller = accessory.value.services.typed().first
        
    }
    
    @ViewBuilder
    var body: some View {
        VStack {
            if self.controller != nil {
                LabeledView(label: Text(self.controller!.statusFault.name), content: {
                    TotalStateView(self.controller!)
                })
            }
            
            WrapperView(style: .outset) {
                HomeBatteryAccessoryDetailView(accessory: self.accessory)
            }
        }
    }
}
