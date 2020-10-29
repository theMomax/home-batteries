//
//  OutletDetailView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 27.09.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import SwiftUI

struct OutletDetailView: View {
    
    @ObservedObject var accessory: Accessory
    
    @ObservedObject var on: Characteristic<Bool>
    @ObservedObject var outletInUse: Characteristic<Bool>
    
    let meter: ElectricityMeterService?
    @ObservedObject var currentPower: Characteristic<Float>
       
    init(accessory: Accessory) {
        self.accessory = accessory
        
        let outlet: OutletService = accessory.value.services.typed().first!
        
        self.on = outlet.on.observable()
        self.outletInUse = outlet.outletInUse.observable()

        if let meter: ElectricityMeterService = accessory.value.services.typed().first {
            self.meter = meter
            self.currentPower = meter.power.observable()
        } else {
            self.meter = nil
            self.currentPower = Characteristic<Float>()
        }
    }
    
    @ViewBuilder
    var body: some View {
        VStack {
            CharacteristicElementView(self.on)
            
            CharacteristicElementView(self.outletInUse)
            
            if currentPower.present {
                CharacteristicElementView(self.currentPower)
            }
            
            if self.meter != nil && self.meter is KoogeekElectricityMeterService {
                OutletDiagramView(accessory: self.accessory)
            }
        }
    }
    
}
