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
            FavouritesTab(home: self.home).tabItem {
                VStack {
                    Image(systemName: "star.fill").font(Font.system(.headline))
                    Text("Favourites")
                }
            }.tag(1)
            RoomsTab(home: self.home).tabItem {
                VStack {
                    Image(systemName: "square.grid.2x2").font(Font.system(.headline))
                    Text("Rooms")
                }
            }.tag(2)
        }
        .navigationBarTitle(Text(home.home.name))
    }
}

struct FavouritesTab: View {
    
    @ObservedObject var home: Home
    
    var body: some View {
        Text("Favourites")
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
        var rooms = self.home.home.rooms
        rooms.append(self.home.home.roomForEntireHome())
        return rooms
    }
    
}

struct HomeView_Previews: PreviewProvider {
    
    @ViewBuilder
    static var previews: some View {
        if HomeStore.shared.homes.first != nil {
            HomeView(home: HomeStore.shared.homes.first!)
        } else {
            NoHomesView()
        }
    }
}
