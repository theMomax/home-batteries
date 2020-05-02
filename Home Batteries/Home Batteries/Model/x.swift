//
//  Room.swift
//  Home Batteries
//
//  Created by Max Obermeier on 01.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import Combine


/// - Tag: Room
class Room: NSObject, ObservableObject, HMHomeDelegate {
    
    private home: HMHome
    
    let room: HMRoom
    
    @Published var name: String
    
    @Published var accessories: [HMAccessory]
    
    init(_ room: HMRoom) {
        self.room = room
        self.name = room.name
        self.accessories = room.accessories
        
        super.init()
        
        self.room.delegate = self
    }
    
    func homeDidUpdateName(_ home: HMHome) {
        guard home == self.home else { return }
        print("home name updated")
        self.name = home.name
    }
  
    func home(_ home: HMHome, didAdd room: HMRoom) {
        guard home == self.home else { return }
        print("room was added to home")
        self.rooms.append(room)
    }
    
    
    func home(_ home: HMHome, didRemove room: HMRoom) {
        guard home == self.home else { return }
        print("room was removed from home")
        self.rooms.removeAll(where: { r in
            return room.uniqueIdentifier == r.uniqueIdentifier
        })
    }
    
    func home(_ home: HMHome, didUpdate room: HMRoom, for accessory: HMAccessory) {
        <#code#>
    }
}
