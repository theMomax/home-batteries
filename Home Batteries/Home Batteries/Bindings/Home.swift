//
//  Home.swift
//  Home Batteries
//
//  Created by Max Obermeier on 01.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import Combine


/// - Tag: Home
class Home: NSObject, ObservableObject, HMHomeDelegate {
    
    @Published var value: HMHome
    
    @Published private(set) var room: HMRoom?
    
    
    private let filter: (HMAccessory) -> Bool = { a in
        a.services.contains(where: { service in AccessoriesView.supportedServices.contains(service.serviceType)})
    }
    
    init(_ home: HMHome) {
        self.value = home
        self.room = home.rooms.first ?? home.roomForEntireHome()
        
        super.init()
        
        self.value.delegate = HomeStore.shared
        
        HomeStore.shared.addHomeDelegate(self)
    }
    
    deinit {
        HomeStore.shared.removeHomeDelegate(self)
    }
    
    func updateRoom(_ room: HMRoom?) {
        self.room = room
    }
    
    func homeDidUpdateName(_ home: HMHome) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func homeDidUpdateAccessControl(forCurrentUser home: HMHome) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didAdd accessory: HMAccessory) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didRemove accessory: HMAccessory) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didAdd user: HMUser) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didRemove user: HMUser) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didUpdate room: HMRoom, for accessory: HMAccessory) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didAdd room: HMRoom) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didRemove room: HMRoom) {
        guard home == self.value else { return }
        self.value = home
        if self.room?.uniqueIdentifier == room.uniqueIdentifier {
            updateRoom(nil)
        }
    }
    
    func home(_ home: HMHome, didUpdateNameFor room: HMRoom) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didAdd zone: HMZone) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didRemove zone: HMZone) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didUpdateNameFor zone: HMZone) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didAdd room: HMRoom, to zone: HMZone) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didRemove room: HMRoom, from zone: HMZone) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didAdd group: HMServiceGroup) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didRemove group: HMServiceGroup) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didUpdateNameFor group: HMServiceGroup) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didAdd service: HMService, to group: HMServiceGroup) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didRemove service: HMService, from group: HMServiceGroup) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didAdd actionSet: HMActionSet) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didRemove actionSet: HMActionSet) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didUpdateNameFor actionSet: HMActionSet) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didUpdateActionsFor actionSet: HMActionSet) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didAdd trigger: HMTrigger) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didRemove trigger: HMTrigger) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didUpdateNameFor trigger: HMTrigger) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didUpdate trigger: HMTrigger) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didUnblockAccessory accessory: HMAccessory) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didEncounterError error: Error, for accessory: HMAccessory) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func home(_ home: HMHome, didUpdate homeHubState: HMHomeHubState) {
        guard home == self.value else { return }
        self.value = home
    }
    
    func homeDidUpdateSupportedFeatures(_ home: HMHome) {
        guard home == self.value else { return }
        self.value = home
    }
}
