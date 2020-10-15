//
//  KnownVisualization.swift
//  Home Batteries
//
//  Created by Max Obermeier on 15.10.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import SwiftUI

extension HMAccessory {
    @ViewBuilder
    func view() -> some View {
        if self.services.known().contains(where: { s in s is OutletService}) {
            OutletQuickView(accessory: Accessory(self))
        } else if self.services.known().contains(where: { s in s is ElectricVehicleChargingStationService}) {
            ChargingStationQuickView(accessory: Accessory(self))
        } else {
            HomeBatteryAccessoryQickView(accessory: Accessory(self))
        }
    }
}
