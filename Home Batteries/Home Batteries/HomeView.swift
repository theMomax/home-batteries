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
import BatteryView

struct HomeView: View {
    
    @EnvironmentObject var hm: HomeManger
    
    var body: some View {
        TabView {
            HomeTab().tabItem {
                VStack {
                    Image(systemName: "house.fill").font(Font.system(.headline))
                    Text("Home")
                }
            }.tag(1)
            RoomsTab().tabItem {
                VStack {
                    Image(systemName: "rectangle.3.offgrid.fill").font(Font.system(.headline))
                    Text("Rooms")
                }
            }.tag(2)
            AutomationTab().tabItem {
                VStack {
                    Image(systemName: "alarm.fill").font(Font.system(.headline))
                    Text("Automation")
                }
            }.tag(3)
        }
    }
}

struct HomeTab: View {
    
    @EnvironmentObject var hm: HomeManger
    
    @State private var showActionSheet: Bool = false
    
    var body: some View {
        NavigationView {
            AccessoriesView(home: self.hm.selected!, showRoomOnly: .constant(false))
            
            .navigationBarTitle(self.hm.selected!.value.name)
                
            .navigationBarItems(leading: Button(action: {
                self.showActionSheet = true
            }, label: {
                ZStack {
                    Image(systemName: "house").foregroundColor(.gray).offset(x: 0.0, y: -1.5)
                }
            }).secondaryCircleButtonStyle().scaleEffect(0.88), trailing: AccessoriesView.addAccessoryButton(home: self.hm.selected!.value))
                
            .actionSheet(isPresented: self.$showActionSheet) {
                ActionSheet(title: Text("Selct Home"), buttons: self.homesToActionSheetButtons() + [.cancel({
                    self.showActionSheet = false
                })])
            }
        }
    }
    
    private func homesToActionSheetButtons() -> [ActionSheet.Button] {
        return self.hm.value.homes.map({h in
            .default(Text(h.name), action: {
                self.showActionSheet = false
                self.hm.selected = Home(h)
            })
        })
    }
    
}

struct RoomsTab: View {
    
    @EnvironmentObject var hm: HomeManger
    
    @State private var showActionSheet: Bool = false
    
    var body: some View {
        NavigationView {
            AccessoriesView(home: self.hm.selected!, showRoomOnly: .constant(true))
            
            .navigationBarTitle(self.hm.selected!.room!.name)
                
            .navigationBarItems(leading: Button(action: {
                self.showActionSheet = true
            }, label: {
                ZStack {
                    Image(systemName: "list.bullet").foregroundColor(.gray)
                }
                }).secondaryCircleButtonStyle(), trailing: AccessoriesView.addAccessoryButton(home: self.hm.selected!.value))
                
            .actionSheet(isPresented: self.$showActionSheet) {
                ActionSheet(title: Text("Selct Room"), buttons: self.roomsToActionSheetButtons() + [.cancel({
                    self.showActionSheet = false
                })])
            }
        }
    }
    
    private func roomsToActionSheetButtons() -> [ActionSheet.Button] {
        return allRooms().map({r in
            .default(Text(r.name), action: {
                self.showActionSheet = false
                self.hm.selected!.updateRoom(r)
            })
        })
    }
    
    private func allRooms() -> [HMRoom] {
        var rooms = self.hm.selected!.value.rooms
        rooms.append(self.hm.selected!.value.roomForEntireHome())
        return rooms
    }
    
}

struct AutomationTab: View {

    @EnvironmentObject var hm: HomeManger

    var body: some View {
        NavigationView {
            AutomationsView(home: hm.selected!)
            
            .navigationBarTitle("Automation")
        }
    }
}
