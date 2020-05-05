//
//  HomeView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 29.04.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI
import HomeKit

struct HomeView: View {
    
    @ObservedObject var home: Home
    
    var body: some View {
        TabView {
            HomeTab(home: self.home).tabItem {
                VStack {
                    Image(systemName: "house.fill").font(Font.system(.headline))
                    Text("Home")
                }
            }.tag(1)
            RoomsTab(home: self.home).tabItem {
                VStack {
                    Image(systemName: "square.grid.2x2").font(Font.system(.headline))
                    Text("Rooms")
                }
            }.tag(2)
        }
        .navigationBarTitle(Text(home.value.name))
    }
}

struct HomeTab: View {
    
    @ObservedObject var home: Home
    
    var body: some View {
        AccessoriesView(accessories: home.value.accessories)
    }
    
}

struct RoomsTab: View {
    
    @ObservedObject var home: Home
    
    var body: some View {
        List(self.allRooms(), id: \.name) { room in
            NavigationLink(destination: AccessoriesView(accessories: room.accessories).navigationBarTitle(room.name), label: {
                Text(room.name)
            })
        }
    }
    
    private func allRooms() -> [HMRoom] {
        var rooms = self.home.value.rooms
        rooms.append(self.home.value.roomForEntireHome())
        return rooms
    }
    
}
