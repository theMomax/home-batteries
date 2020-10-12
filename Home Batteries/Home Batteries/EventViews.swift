//
//  EventViews.swift
//  Home Batteries
//
//  Created by Max Obermeier on 09.06.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI
import HomeKit
import CoreLocation


// MARK: NewEventView
struct NewEventView: View {
    
    enum CharacteristicEventType: String {
        case equality = "is equal to"
        case lessOrEqual = "is less than or equal to"
        case greaterOrEqual = "is greater than or equal to"
        case between = "is between"
        
        static func all() -> [CharacteristicEventType] {
            return [.equality, .lessOrEqual, .greaterOrEqual, .between]
        }
    }
    
    @EnvironmentObject var home: Home
    
    @ObservedObject var trigger: Trigger<HMEventTrigger>
    
    let done: (_: HMEvent?) -> ()
    
    private var validConfiguration: Bool {
        get {
            if self.characteristic == nil {
                return false
            }
            switch self.type {
            case .equality:
                if let c = CurrentPower.isContinuous(self.characteristic!) {
                    if c {
                        return CurrentPower.isValid(self.firstBoundary, for: self.characteristic!)
                    } else {
                        return CurrentPower.isValid(self.selection, for: self.characteristic!)
                    }
                } else {
                    return false
                }
            case .lessOrEqual, .greaterOrEqual:
                return CurrentPower.isValid(self.firstBoundary, for: self.characteristic!)
            case .between:
                return CurrentPower.isValid(self.firstBoundary, for: self.characteristic!) && CurrentPower.isValid(self.secondBoundary, for: self.characteristic!) && Float(self.firstBoundary)! <= Float(self.secondBoundary)!
            }
        }
    }
    
    @State private var characteristic: HMCharacteristic? = nil
    
    @State private var type: CharacteristicEventType = .equality
    
    @State private var selection: NSNumber = 0
    
    @State private var firstBoundary: String = ""
    
    @State private var secondBoundary: String = ""
    
    
    @ViewBuilder
    var body: some View {
        NavigationView {
            VStack {
                WrapperView(edges: .top) {
                    if self.characteristic == nil {
                        NavigationLink(destination: RoomPickerView(characteristic: self.$characteristic).environmentObject(self.home), label: {
                            HStack {
                                Image(systemName: "skew").font(Font.system(.title)).foregroundColor(.accentColor)
                                Text("Select a characteristic")
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.secondary).font(Font.system(.footnote))
                            }
                        })
                    } else {
                        HStack {
                            Image(systemName: "skew").font(Font.system(.title)).foregroundColor(.accentColor)
                            Text(CurrentPower.description(self.characteristic!))
                            Spacer()
                            Button(action: {
                                self.characteristic = nil
                                self.type = .equality
                            }, label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.accentColor)
                            })
                        }
                    }
                    
                }

                if self.characteristic != nil {
                    
                    if CurrentPower.isContinuous(self.characteristic!) == nil {
                        Text("Cannot interprete this characteristic. Please select a different characteristic or use a different app to create this trigger.").multilineTextAlignment(.center).lineLimit(nil).fixedSize(horizontal: false, vertical: true).foregroundColor(.secondary).padding(.vertical)
                    } else if CurrentPower.isContinuous(self.characteristic!)! {
                        Picker(selection: self.$type, label: EmptyView()) {
                            ForEach(CharacteristicEventType.all(), id: \.rawValue) { t in
                                Text(t.rawValue).tag(t)
                            }
                        }
                        
                        WrapperView(edges: .bottom) {
                            HStack {
                                TextField(self.type == .equality ? "value" : self.type == .lessOrEqual ? "upper bound" : "lower bound", text: self.$firstBoundary, onCommit:  {
                                    UIApplication.shared.endEditing()
                                })
                                .keyboardType(.numbersAndPunctuation)
                                Text(CurrentPower.unit(self.characteristic!))
                            }
                        }
                        
                        if self.type == .between {
                            Text("and").padding(.bottom)
                            
                            WrapperView(edges: .bottom) {
                                HStack {
                                    TextField("upper bound", text: self.$secondBoundary, onCommit:  {
                                        UIApplication.shared.endEditing()
                                    })
                                    .keyboardType(.numbersAndPunctuation)
                                    Text(CurrentPower.unit(self.characteristic!))
                                }
                            }
                        }
                        
                    } else {
                        Text(CharacteristicEventType.equality.rawValue).padding(.top)
                        
                        Picker(selection: self.$selection, label: EmptyView()) {
                            ForEach(self.characteristic!.metadata!.validValues!, id: \.description) { v in
                                Text(CurrentPower.format(v, as: self.characteristic!)).tag(v)
                            }
                        }
                    }
                }
                
                Spacer().layoutPriority(4)
            }.padding()
            .navigationBarTitle("Add a trigger", displayMode: .inline)
            .navigationBarItems(leading: Button(action: { self.done(nil) }, label: {
                Text("Cancel").foregroundColor(.red)
            }), trailing: Button(action: {
                var event: HMEvent
                switch self.type {
                case .equality:
                    if CurrentPower.isContinuous(self.characteristic!)! {
                        event =  HMCharacteristicEvent<NSCopying>(characteristic: self.characteristic!, triggerValue: NSNumber(value: Float(self.firstBoundary)!))
                    } else {
                        event =  HMCharacteristicEvent<NSCopying>(characteristic: self.characteristic!, triggerValue: self.selection)
                    }
                default:
                    var range: HMNumberRange
                    switch self.type {
                    case .lessOrEqual:
                        range = HMNumberRange(maxValue: NSNumber(value: Float(self.firstBoundary)!))
                    case .greaterOrEqual:
                        range = HMNumberRange(minValue: NSNumber(value: Float(self.firstBoundary)!))
                    default:
                        range = HMNumberRange(minValue: NSNumber(value: Float(self.firstBoundary)!), maxValue: NSNumber(value: Float(self.secondBoundary)!))
                    }
                    
                    event = HMCharacteristicThresholdRangeEvent(characteristic: self.characteristic!, thresholdRange: range)
                }
                self.done(event)
            }, label: {
                Text("Done").foregroundColor(.accentColor)
            })
            .disabled(!self.validConfiguration))
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

// MARK: PresenceEventOverviewView
struct PresenceEventOverviewView: View {
    
    let event: HMPresenceEvent
    
    var body: some View {
        HStack {
            Image(systemName: "house").font(.headline).foregroundColor(.primary)
            Text(Self.description(self.event))
            Spacer()
        }
    }
    
    static func description(_ event: HMPresenceEvent) -> String {
        var d = ""
        switch event.presenceUserType {
        case .currentUser:
            d += "You"
            switch event.presenceEventType {
            case .everyEntry:
                d += " enter the house"
            case .everyExit:
                d += " leave the house"
            case .firstEntry:
                d += " enter the house and nobody else is at home"
            case .lastExit:
                d += " leave the house and nobody else is at home"
            default:
                d += " managed to create a weird trigger"
            }
            return d
        case .homeUsers:
            d += "Any resident"
        default:
            d += "A specific person"
        }
        switch event.presenceEventType {
        case .everyEntry:
            d += " enters the house"
        case .everyExit:
            d += " leaves the house"
        case .firstEntry:
            d += " enters the house and nobody else is at home"
        case .lastExit:
            d += " leaves the house and nobody else is at home"
        default:
            d += " managed to create a weird trigger"
        }
        return d
    }
}

// MARK: LocationEventOverviewView
struct LocationEventOverviewView: View {
    
    let event: HMLocationEvent
    
    @ObservedObject var lm: LocationManager = LocationManager()
    
    init(event: HMLocationEvent) {
        self.event = event
        
        let cllm = CLLocationManager()
        
        if cllm.authorizationStatus == .notDetermined {
            self.lm.value.requestWhenInUseAuthorization()
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "location").font(.headline).foregroundColor(.primary)
            Text(Self.description(self.event))
            Spacer()
        }
    }
    
    static func description(_ event: HMLocationEvent) -> String {        
        if let r = event.region {
            switch r {
            case r as CLCircularRegion:
                return "You \(r.notifyOnEntry ? "arrive at" : "leave") " + r.identifier
            default:
                return "You \(r.notifyOnEntry ? "arrive at" : "leave") " + r.identifier
            }
        } else {
            return "You arrive at or leave some location"
        }
    }
}

// MARK: TimeEventOverviewView
struct TimeEventOverviewView: View {
    
    let event: HMTimeEvent
    
    var body: some View {
        HStack {
            Self.icon(self.event).font(.headline).foregroundColor(.primary)
            Text(Self.description(self.event))
            Spacer()
        }
    }
    
    static func icon(_ event: HMTimeEvent) -> Image {
        switch event {
        case _ as HMSignificantTimeEvent:
            return Image(systemName: "sun.dust")
        case _ as HMDurationEvent:
            return Image(systemName: "timer")
        default:
            return Image(systemName: "clock")
        }
    }
    
    static func description(_ event: HMTimeEvent) -> String {
        switch event {
        case let e as HMDurationEvent:
            return Self.description(e.duration)
        case let e as HMCalendarEvent:
            return Self.description(absolute: e.fireDateComponents)
        case let e as HMSignificantTimeEvent:
            return "\(Self.description(relative: e.offset)) \(e.significantEvent == HMSignificantEvent.sunset ? "sunset" : "sunrise")"
        default:
            return "???"
        }
    }
    
    private static func description(_ duration: TimeInterval) -> String {
        var d = "After "
        var dur = duration
        for (t, singular, plural) in [(3600.0, "hour", "hours"), (60.0, "minute", "minutes"), (1.0, "second", "seconds")] {
            switch Int((dur / t).rounded()) {
            case 1:
                d += "1" + " " + singular
            case let n where n > 1:
                d += String(n) + " " + plural
            default:
                break
            }
            dur = dur.remainder(dividingBy: TimeInterval(t))
        }
        return d
    }
    
    private static func description(absolute components: DateComponents?) -> String {
        if let dc = components {
            return String(format: "%02d:%02d", dc.hour! % 12, dc.minute!) + " " + (dc.hour! > 12 ? "pm" : "am")
        } else {
            return "unknown time"
        }
    }
    
    private static func description(relative components: DateComponents?) -> String {
        if let dc = components {
            if dc.isZero {
                return "At"
            }
            
            var d = ""
            if let h = dc.hour {
                if h != 0 {
                    d += "\(abs(h)) \(abs(h) == 1 ? "hour" : "hours")"
                }
            }
            if dc.hour ?? 0 != 0 && dc.minute ?? 0 != 0 {
                d += " and "
            }
            if let m = dc.minute {
                if m != 0 {
                    d += "\(abs(m)) \(abs(m) == 1 ? "minute" : "minutes")"
                }
            }
            
            if dc.isBefore {
                d += " before"
            } else {
                d += " after"
            }
            
            return d
        } else {
            return "At"
        }
    }
}

extension DateComponents {
    var isZero: Bool {
        return (self.hour == nil || self.hour! == 0) && (self.minute == nil || self.minute! == 0)
    }
    
    var isBefore: Bool {
        return self.hour ?? 0 < 0 || self.minute ?? 0 < 0
    }
}
