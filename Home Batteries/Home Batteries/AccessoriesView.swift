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
    
    @ObservedObject var home: Home
    
    @Binding var showRoomOnly: Bool
    
    
    var body: some View {
        self.content(accessories: Self.homeBatteryAccessories(home: self.home, room: self.showRoomOnly ? self.home.room! : nil).map(Accessory.init))
    }
    
    @ViewBuilder
    private func content(accessories: [Accessory]) -> some View {
        ScrollView {
            if accessories.isEmpty {
                WrapperView(boxed: false) {
                    Text("No supported accessories here...").foregroundColor(.secondary)
                }
            } else {
                ForEach(accessories, id: \.value.uniqueIdentifier) { a in
                    AccessoryOverviewView(accessory: a)
                }.padding(.vertical)
            }
        }
    }
    
    private static func homeBatteryAccessories(home: Home, room: HMRoom?) -> [HMAccessory] {
        var accessories: [HMAccessory]
        if let room = room {
            accessories = room.accessories
        } else {
            accessories = home.value.accessories
        }
        
        return accessories.filter({ a in
            a.services.contains(where: { service in AccessoriesView.supportedServices.contains(service.serviceType)} )
        })
    }
}

