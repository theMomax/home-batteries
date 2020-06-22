//
//  AccessoriesView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 01.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import WaterfallGrid
import SwiftUI
import HomeKit

struct AccessoriesView: View {
    
    @ObservedObject var home: Home
    
    @Binding var showRoomOnly: Bool
    
    let padding: CGFloat = 20
    
    var body: some View {
        self.content(accessories: Self.knownAccessories(home: self.home, room: self.showRoomOnly ? self.home.room! : nil).map(Accessory.init))
    }
    
    @ViewBuilder
    private func content(accessories: [Accessory]) -> some View {
        GeometryReader { (geo: GeometryProxy) in
            if accessories.isEmpty {
                WrapperView(boxed: false) {
                    Text("No supported accessories here...").foregroundColor(.secondary)
                }
            } else {
                self.grid(accessories: accessories, geo: geo)
            }
        }
    }
    
    private func grid(accessories: [Accessory], geo: GeometryProxy) -> some View {
        WaterfallGrid(accessories, id: \.value.uniqueIdentifier) { a in
            HomeBatteryAccessoryQickView(accessory: a).frame(height: (geo.size.width - 3*self.padding)/2 )
        }
        .gridStyle(columns: 2, spacing: self.padding, padding: .init(top: self.padding, leading: self.padding, bottom: self.padding, trailing: self.padding), animation: nil)
    }
    
    private static func knownAccessories(home: Home, room: HMRoom?) -> [HMAccessory] {
        var accessories: [HMAccessory]
        if let room = room {
            accessories = room.accessories
        } else {
            accessories = home.value.accessories
        }
        
        return accessories.filter({ a in a.known()})
    }
}

