//
//  IntentHandler.swift
//  AccessorySelection
//
//  Created by Max Obermeier on 15.10.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Intents
import HomeKit

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

extension IntentHandler: SelectAccessoryIntentHandling {
    func resolveAccessory(for intent: SelectAccessoryIntent, with completion: @escaping (IAccessoryResolutionResult) -> Void) {
        
    }
    
    func provideAccessoryOptionsCollection(for intent: SelectAccessoryIntent, with completion: @escaping (INObjectCollection<IAccessory>?, Error?) -> Void) {
        let hm = HomeStore.shared.homeManager
        // take a short nap until the connection to the local HomeKit instance is established (otherwise below code won't create an empty array on first call)
        sleep(1)
        
        let accessories = hm.homes.flatMap({ h in h.accessories.map({a in (a, h)})}).filter({(a, _) in a.known()}).map({ (a: HMAccessory, h: HMHome) -> IAccessory in
            let roomName = a.room?.name ?? "Default-Room"
            let homeName = h.name
            
            let accessory = IAccessory(identifier: a.uniqueIdentifier.uuidString, display: "\(a.name) (\(homeName), \(roomName))")
            accessory.name = a.name
            accessory.home = IHome(identifier: h.uniqueIdentifier.uuidString, display: homeName)
            accessory.home!.name = homeName
            
            if let r = a.room {
                accessory.room = IRoom(identifier: r.uniqueIdentifier.uuidString, display: roomName)
                accessory.room!.name = roomName
            } else {
                accessory.room = IRoom(identifier: "0", display: roomName)
                accessory.room!.name = roomName
            }
            
            return accessory
        })
        
        completion(INObjectCollection(items: accessories), nil)
    }
}
