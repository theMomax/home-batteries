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
       
    init(accessory: Accessory) {
        self.accessory = accessory
        
        let service: OutletService = accessory.value.services.typed().first!
        
        self.on = service.on.observable()
        self.outletInUse = service.outletInUse.observable()
    }
    
    @ViewBuilder
    var body: some View {
        VStack {
            CharacteristicElementView(self.on)
            
            CharacteristicElementView(self.outletInUse)
        }
    }
    
}
