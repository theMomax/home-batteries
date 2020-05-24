//
//  CharacteristicEventView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 22.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI
import HomeKit


struct CharacteristicEventOverviewView: View {
    
    @ObservedObject var event: CharacteristicEvent<HMCharacteristicEvent<NSCopying>>
    
    var body: some View {
        HStack {
            Image(systemName: "skew").font(.title).foregroundColor(.accentColor)
            Text(self.eventDescription()).fixedSize(horizontal: false, vertical: true).foregroundColor(.primary)
            Spacer()
        }
    }
    
    private func eventDescription() -> String {
        let characteristic = CurrentPower.description(self.event.value.characteristic)
        if self.event.value.triggerValue == nil {
            return characteristic + " changes"
        }
        switch self.event.value.triggerValue! {
        case let v as CustomStringConvertible:
            return characteristic + " is " + v.description + CurrentPower.unit(self.event.value.characteristic)
        default:
            return characteristic + " is some value"
        }
    }
}

struct CharacteristicThresholdRangeEventOverviewView: View {

    @ObservedObject var event: CharacteristicEvent<HMCharacteristicThresholdRangeEvent>

    var body: some View {
        HStack {
            Image(systemName: "skew").font(.title).foregroundColor(.accentColor)
            Text(self.eventDescription()).fixedSize(horizontal: false, vertical: true).foregroundColor(.primary)
            Spacer()
        }
    }

    private func eventDescription() -> String {
        var d = CurrentPower.description(self.event.value.characteristic)

        if let min = self.event.value.thresholdRange.minValue {
            d += " is greater than or equal to " + min.description + CurrentPower.unit(self.event.value.characteristic)
        }
        
        if self.event.value.thresholdRange.minValue == nil && self.event.value.thresholdRange.maxValue == nil {
            d += " and"
        }
        
        if let max = self.event.value.thresholdRange.maxValue {
            d += " is less than or equal to " + max.description + CurrentPower.unit(self.event.value.characteristic)
        }
        
        return d
    }
}
