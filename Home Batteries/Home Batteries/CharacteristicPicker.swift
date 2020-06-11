//
//  CharacteristicPicker.swift
//  Home Batteries
//
//  Created by Max Obermeier on 27.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI
import HomeKit

struct RoomPickerView: View {
    
    @EnvironmentObject var home: Home
    
    @Binding var characteristic: HMCharacteristic?
    
    var body: some View {
        ScrollView {
            ForEach(self.home.value.rooms + [self.home.value.roomForEntireHome()], id: \.uniqueIdentifier) { room in
                WrapperView(edges: .init(arrayLiteral: .top, .horizontal)) {
                    NavigationLink(destination: AccessoryPickerView(characteristic: self.$characteristic, room: room), label: {
                        Image(systemName: "rectangle.3.offgrid.fill").font(.headline).foregroundColor(.accentColor)
                        Text(room.name).foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.secondary).font(Font.system(.footnote))
                    }).isDetailLink(false)
                }
            }
            .padding(.bottom)
        }.padding(.top)
        .navigationBarTitle("Rooms")
    }
    
}

struct AccessoryPickerView: View {
    
    @EnvironmentObject var home: Home
    
    @Binding var characteristic: HMCharacteristic?
    
    let room: HMRoom
    
    var body: some View {
        ScrollView {
            ForEach(self.room.accessories.filter({a in a.known() != nil}), id: \.uniqueIdentifier) { accessory in
                WrapperView(edges: .init(arrayLiteral: .top, .horizontal)) {
                    NavigationLink(destination: ServicePickerView(characteristic: self.$characteristic, accessory: accessory), label: {
                        Image(systemName: "lightbulb").font(.headline).foregroundColor(.accentColor)
                        Text(accessory.name).foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.secondary).font(Font.system(.footnote))
                    }).isDetailLink(false)
                }
            }
            .padding(.bottom)
        }.padding(.top)
        .navigationBarTitle("Accessories")
    }
    
}

struct ServicePickerView: View {
    
    @EnvironmentObject var home: Home
    
    @Binding var characteristic: HMCharacteristic?
    
    let accessory: HMAccessory
    
    var body: some View {
        ScrollView {
            ForEach(self.accessory.services.filter({s in s.known() != nil}), id: \.uniqueIdentifier) { service in
                WrapperView(edges: .init(arrayLiteral: .top, .horizontal)) {
                    NavigationLink(destination: CharacteristicPickerView(characteristic: self.$characteristic, service: service), label: {
                        Image(systemName: "gear").font(.headline).foregroundColor(.accentColor)
                        Text(service.name).foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.secondary).font(Font.system(.footnote))
                    }).isDetailLink(false)
                }
            }
            .padding(.bottom)
        }.padding(.vertical)
        .navigationBarTitle("Services")
    }
    
}

struct CharacteristicPickerView: View {
    
    @EnvironmentObject var home: Home
    
    @Binding var characteristic: HMCharacteristic?
    
    let service: HMService
    
    var body: some View {
        ScrollView {
            ForEach(self.service.characteristics.filter({c in c.known() != nil}), id: \.uniqueIdentifier) { characteristic in
                WrapperView(edges: .init(arrayLiteral: .top, .horizontal)) {
                    Button(action: {
                        self.characteristic = characteristic
                    }, label: {
                        Image(systemName: "skew").font(.headline).foregroundColor(.accentColor)
                        Text(CurrentPower.name(characteristic)).foregroundColor(.primary)
                        Spacer()
                        Text("Select")
                    })
                }
            }
            .padding(.bottom)
        }.padding(.top)
        .navigationBarTitle("Characteristics")
        
    }
    
}
