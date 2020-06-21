//
//  KnownAccessory.swift
//  Home Batteries
//
//  Created by Max Obermeier on 02.06.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit

extension HMAccessory {
    func known() -> Bool {
        return !self.services.known().isEmpty
    }
}

extension Array where Element == HMService {
    func known() -> [KnownService] {
        return self.map({s in s.known()}).filter({s in s != nil}).map({s in s!})
    }
    
    func typed<T : KnownService>() -> [T] {
        return self.map({s in s.known() as? T }).filter({s in s != nil}).map({s in s!})
    }
}
