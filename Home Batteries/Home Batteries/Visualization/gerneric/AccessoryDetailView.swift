//
//  AccessoryDetailView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 24.09.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import SwiftUI


struct AccessoryDetailView<Content>: View where Content: View {
    
    @ObservedObject var accessory: Accessory
    
    private let content: () -> Content
    
    @Binding var isPresented: Bool
    
    let onDismiss: (() -> Void)?
    
    init(accessory: Accessory, isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.accessory = accessory
        self.content = content
        self._isPresented = Binding<Bool>(get: {
            let value = isPresented.wrappedValue
            print("isPresented = \(value) (get)")
            return value
        }, set: { newValue in
            print("isPresented = \(newValue) (set)")
            isPresented.wrappedValue = newValue
        })
        self.onDismiss = onDismiss
    }
    
    @ViewBuilder
    var body: some View {
        Color.clear
        .sheet(isPresented: self.$isPresented, content: {
            VStack(spacing: 0) {
                HStack {
                    Text(self.accessory.value.name).bold().padding(.leading)
                    Spacer()
                    CloseButton(action: {
                        self.isPresented = false
                        (self.onDismiss ?? {})()
                    })
                }.padding().background(Color.secondaryOutsetBackground)
                Divider()
                ScrollView {
                    Spacer(minLength: 30)
                    
                    if self.accessory.value.isReachable {
                        self.content()
                    } else {
                        WrapperView(style: .outset) {
                            ConnectingToAccessoryView(accessory: self.$accessory.value)
                        }
                    }
                    
                    GenericInfoView(accessory: self.accessory)
                    
                    Spacer(minLength: 30)
                }
            }
            .background(Color.tintedBackground).edgesIgnoringSafeArea(.bottom)
        })
    }
    
}

extension View {
    func withAccessoryDetail<Content>(accessory: Accessory, isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        ZStack {
            self
            AccessoryDetailView(accessory: accessory, isPresented: isPresented, onDismiss: onDismiss, content: content)
        }
    }
}

struct GenericInfoView: View {
    
    @ObservedObject var accessory: Accessory
    
    @ViewBuilder
    var body: some View {
        VStack {
            LabeledTextView(label: "Room", content: self.accessory.value.room?.name ?? "Default Room")
            
            WrapperView(innerEdges: .init(arrayLiteral: .leading, .vertical), style: .outset) {
                VStack {
                    ListElementView(label: "Manufacturer", content: self.accessory.value.manufacturer ?? "Default-Manufacturer")
                    Divider()
                    ListElementView(label: "Model", content: self.accessory.value.model ?? "Default-Model")
                    Divider()
                    ListElementView(label: "Firmware", content: self.accessory.value.firmwareVersion ?? "Default-Firmware")
                }
            }
        }
    }
}

struct LabeledView<Content>: View where Content: View {
    
    private let wrapper: Bool
    
    private let label: Text
    
    private let content: () -> Content
    
    init(wrapper: Bool = true, label: Text, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
        self.wrapper = wrapper
    }
    
    var body: some View {
        if self.wrapper {
            WrapperView(style: .outset) {
                HStack {
                    self.label
                    Spacer()
                    self.content()
                }
            }
        } else {
            HStack {
                self.label
                Spacer()
                self.content()
            }.padding()
        }
    }
}

struct LabeledTextView: View {
    private let wrapper: Bool
    
    private let label: Text
    
    private let content: Text
    
    init(wrapper: Bool = true, label: Text, content: Text) {
        self.label = label
        self.content = content
        self.wrapper = wrapper
    }
    
    init(wrapper: Bool = true, label: String, content: String) {
        self.init(wrapper: wrapper, label: Text(label), content: Text(content).foregroundColor(.secondary))
    }
    
    var body: some View {
        LabeledView(wrapper: self.wrapper, label: self.label, content: {self.content.foregroundColor(.secondary)})
    }
}

struct ListElementView: View {
    
    private let label: Text
    
    private let content: Text
    
    init(label: Text, content: Text) {
        self.label = label
        self.content = content.foregroundColor(.secondary)
    }
    
    init(label: String, content: String) {
        self.init(label: Text(label), content: Text(content).foregroundColor(.secondary))
    }
    
    var body: some View {
        HStack {
            self.label
            Spacer()
            self.content
        }.padding(.trailing)
    }
}

struct CharacteristicView<T, Content>: View where Content : View {
    @ObservedObject var characteristic: Characteristic<T>
    
    private let name: String
    
    private let format: (_: T?) -> String
    
    private let view: (_: Text, _: Text) -> Content
    
    init(_ characteristic: Characteristic<T>,  view: @escaping (_: Text, _: Text) -> Content) {
        self.characteristic = characteristic
        self.view = view
        
        if let k = characteristic.characteristic?.known() {
            self.name = k.name
            self.format = { v in  k.format(v) + (k.unit() == "" ? "" : " " + k.unit())}
        } else {
            self.name = characteristic.characteristic?.description ?? "Unknown characteristic"
            if let c = characteristic.characteristic {
                self.format = { v in CurrentPower.format(v, as: c)}
            } else {
                self.format = { _ in "Unknown value" }
            }
        }
    }
    
    var body: some View {
        self.view(Text(self.name), Text(self.format(self.characteristic.value)))
    }
}

struct CharacteristicElementView<T>: View {
    
    @ObservedObject var characteristic: Characteristic<T>
    
    init(_ characteristic: Characteristic<T>) {
        self.characteristic = characteristic
    }
    
    var body: some View {
        CharacteristicView(self.characteristic, view: {label, value in LabeledTextView(label: label, content: value)})
    }
}

struct CharacteristicListElementView<T>: View {
    
    @ObservedObject var characteristic: Characteristic<T>
    
    init(_ characteristic: Characteristic<T>) {
        self.characteristic = characteristic
    }
    
    var body: some View {
        CharacteristicView(self.characteristic, view: {label, value in ListElementView(label: label, content: value)})
    }
}
