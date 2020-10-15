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
        
        let accessories = hm.homes.flatMap({ h in h.accessories.map({a in (a, h)})}).filter({(a, _) in a.known()}).map({ (a: HMAccessory, h: HMHome) -> IAccessory in
            let accessory = IAccessory(identifier: a.uniqueIdentifier.uuidString, display: a.name)
            accessory.name = a.name
            accessory.home = IHome(identifier: h.uniqueIdentifier.uuidString, display: h.name)
            accessory.home?.name = h.name
            
            if let r = a.room {
                accessory.room = IRoom(identifier: r.uniqueIdentifier.uuidString, display: r.name)
                accessory.room?.name = r.name
            } else {
                accessory.room = IRoom(identifier: "0", display: "Default-Room")
                accessory.room?.name = "Default-Room"
            }
            
            return accessory
        })
        
        completion(INObjectCollection(items: accessories), nil)
    }
}
