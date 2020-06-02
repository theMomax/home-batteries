//
//  KnownAccessory.swift
//  Home Batteries
//
//  Created by Max Obermeier on 02.06.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit

extension HMAccessory {
    func known() -> KnownAccessory? {
        let ka = AnyAccessory(self)
        if ka.services.isEmpty {
            return nil
        } else {
            return ka
        }
    }
}

protocol KnownAccessory {
    var accessory: HMAccessory { get }
    
    init(_ accessory: HMAccessory)
}

extension KnownAccessory {
    var services: [HMService] {
        get {
            return self.accessory.services.filter({s in s.known() != nil})
        }
    }
}

class AnyAccessory: KnownAccessory {
    var accessory: HMAccessory
    
    required init(_ accessory: HMAccessory) {
        self.accessory = accessory
    }
}

