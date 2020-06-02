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
            Image(systemName: "skew").font(.headline).foregroundColor(.accentColor)
            Text(self.eventDescription()).fixedSize(horizontal: false, vertical: true).foregroundColor(.primary)
            Spacer()
        }
    }
    
    private func eventDescription() -> String {
        let characteristic = CurrentPower.description(self.event.value.characteristic)
        if self.event.value.triggerValue == nil {
            return characteristic + " changes"
        }
        return characteristic + " is " + CurrentPower.format(self.event.value.triggerValue, as: self.event.value.characteristic) + CurrentPower.unit(self.event.value.characteristic)
    }
}

struct CharacteristicThresholdRangeEventOverviewView: View {

    @ObservedObject var event: CharacteristicEvent<HMCharacteristicThresholdRangeEvent>

    var body: some View {
        HStack {
            Image(systemName: "skew").font(.headline).foregroundColor(.accentColor)
            Text(self.eventDescription()).fixedSize(horizontal: false, vertical: true).foregroundColor(.primary)
            Spacer()
        }
    }

    private func eventDescription() -> String {
        var d = CurrentPower.description(self.event.value.characteristic)

        if let min = self.event.value.thresholdRange.minValue {
            d += " is greater than or equal to " + min.description + CurrentPower.unit(self.event.value.characteristic)
        }
        
        if self.event.value.thresholdRange.minValue != nil && self.event.value.thresholdRange.maxValue != nil {
            d += " and"
        }
        
        if let max = self.event.value.thresholdRange.maxValue {
            d += " is less than or equal to " + max.description + CurrentPower.unit(self.event.value.characteristic)
        }
        
        return d
    }
}
