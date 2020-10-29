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
    
    @ObservedObject var hourlyEnergyToday: Characteristic<NSData>
       
    init(accessory: Accessory) {
        self.accessory = accessory
        
        let outlet: OutletService = accessory.value.services.typed().first!
        
        self.on = outlet.on.observable()
        self.outletInUse = outlet.outletInUse.observable()
        
        if let meter: KoogeekElectricityMeterService = accessory.value.services.typed().first {
            self.hourlyEnergyToday = meter.hourlyToday.observable(updating: false)
        } else {
            self.hourlyEnergyToday = Characteristic<NSData>()
        }
        
    }
    
    @ViewBuilder
    var body: some View {
        VStack {
            CharacteristicElementView(self.on)
            
            CharacteristicElementView(self.outletInUse)
            
            OutletDiagramView(accessory: self.accessory)
        }
    }
    
}
