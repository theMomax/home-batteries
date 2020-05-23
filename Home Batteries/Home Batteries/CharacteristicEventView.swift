//
//  CharacteristicEventView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 22.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI
import HomeKit

struct CharacteristicEventDetailView: View {
    
    @ObservedObject var event: CharacteristicEvent<HMCharacteristicEvent<NSCopying>>
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let isEndTrigger: Bool = false
    
    var body: some View {
        ScrollView {
            HStack {
                Text(CharacteristicEventOverviewView.eventDescription(self.event.value)).font(.headline).bold().fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
        }
        .padding(.init(arrayLiteral: .horizontal, .bottom))
        .navigationBarTitle(isEndTrigger ? "Until:" : "When:")
    }
}

struct CharacteristicEventOverviewView: View {
    
    @ObservedObject var event: CharacteristicEvent<HMCharacteristicEvent<NSCopying>>
    
    var body: some View {
        HStack {
            NavigationLink(destination: CharacteristicEventDetailView(event: self.event)) {
                Image(systemName: "skew").font(.title).foregroundColor(.accentColor)
                Text(Self.eventDescription(self.event.value)).fixedSize(horizontal: false, vertical: true).foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary).font(Font.system(.footnote))
            }
        }
    }
    
    static func eventDescription(_ event: HMCharacteristicEvent<NSCopying>) -> String {
        return CurrentPower.description(event.characteristic) + " changes"
    }
}
