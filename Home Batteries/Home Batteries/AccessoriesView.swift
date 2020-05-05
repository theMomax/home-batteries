//
//  AccessoriesView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 01.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI
import HomeKit

struct AccessoriesView: View {
    
    static let supportedServices = AccessoryOverviewView.supportedServices
    
    let accessories: [HMAccessory]
    
    var body: some View {
        ScrollView {
            ForEach(homeBatteryAccessories() , id: \.uniqueIdentifier) { (accessory: HMAccessory) in
                AccessoryOverviewView(accessory: Accessory(accessory))
            }.padding(.top)
        }
    }
    
    private func homeBatteryAccessories() -> [HMAccessory] {
        return self.accessories.filter({ a in
            a.services.contains(where: { service in AccessoriesView.supportedServices.contains(service.serviceType)} )
        })
    }
}
