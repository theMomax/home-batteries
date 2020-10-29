//
//  OVMS.swift
//  Home Batteries
//
//  Created by Max Obermeier on 29.10.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit

// MARK: Estimated Range
class EstimatedRange: Range, KnownCharacteristic {
    static let uuid: String = "00000007-0001-1000-8000-0036AC324978"
    static let entityType: String = "Estimated Range"
    
    var characteristic: HMCharacteristic
    
    required init(_ characteristic: HMCharacteristic) {
        self.characteristic = characteristic
    }
    
}
