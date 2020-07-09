//
//  AutomationsView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 20.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI
import HomeKit

// MARK: AutomationsView
struct AutomationsView: View {

    @ObservedObject var home: Home

    @State var showAddSheet: Bool = false
    
    @ViewBuilder
    var body: some View {
        ScrollView {
            HStack {
                HomeHubStateView(state: self.home.value.homeHubState).fixedSize(horizontal: false, vertical: true)
                Spacer()
            }.padding(Edge.Set(arrayLiteral: .horizontal, .bottom))
            
            ForEach(self.home.value.triggers, id: \.uniqueIdentifier) { trigger in
                TriggerOverviewView(trigger: Trigger(trigger, in: self.home.value))
                .contextMenu {
                    Button(action: {
                        self.home.value.removeTrigger(trigger, completionHandler: { err in
                            if let e = err {
                                print(e)
                            } else {
                                withAnimation {
                                    self.home.home(didRemove: trigger)
                                }
                            }
                        })
                    }, label: DeteteContextMenuLabelView.init)
                }
                .padding(.init(arrayLiteral: .top, .horizontal))
            }
            HStack{EmptyView()}.padding(.bottom)
        }.environmentObject(self.home)
        
            
        .navigationBarItems(trailing: Button(action: {
            self.showAddSheet = true
        }, label: {
            ZStack {
                Image(systemName: "plus").foregroundColor(.white)
            }
        }).buttonStyle(CircleButtonStyle(color: .accentColor)))
            
        .sheet(isPresented: self.$showAddSheet) {
            NewTriggerView(done: { _ in
                self.showAddSheet = false
            }).environmentObject(self.home)
        }
    }
}

// MARK: NewTriggerView
struct NewTriggerView: View {
    
    @EnvironmentObject var home: Home
    
    private var validName: Bool {
        get {
            return self.name != "" && !self.home.value.triggers.contains(where: { trigger in trigger.name == self.name})
        }
    }
    
    @State private var name: String = ""
    
    let done: (_ success: Bool) -> ()

    
    var body: some View {
        NavigationView {
            VStack {
                WrapperView(edges: .bottom) {
                    HStack {
                        Image(systemName: "skew").font(Font.system(.title)).foregroundColor(.accentColor)
                        TextField("Name", text: self.$name)
                    }
                }
                if !self.validName {
                    HStack {
                        Spacer()
                        Text("Choose a unique name for your automation").multilineTextAlignment(.center).font(.caption).foregroundColor(.secondary)
                        Spacer()
                    }
                }
                Spacer().layoutPriority(4)
            }.padding()
            .padding(.top)
            .navigationBarTitle("Add an automation", displayMode: .inline)
            .navigationBarItems(leading: Button(action: { self.done(false) }, label: {
                Text("Cancel").foregroundColor(.red)
            })
            , trailing: Button(action: {
                let trigger = HMEventTrigger(name: self.name, events: [], predicate: nil)
                self.home.value.addTrigger(trigger, completionHandler: { err in
                    if let e = err {
                        print(e)
                    } else {
                        self.home.home(didAdd: trigger)
                        self.done(true)
                    }
                })
            }, label: {
                Text("Done").foregroundColor(.accentColor)
            })
            .disabled(!self.validName))
        }
    }
}

// MARK: DeteteContextMenuLabelView
struct DeteteContextMenuLabelView: View {
    var body: some View {
        HStack {
            // styling context menues doesn't work with swiftui to date, so the foregroundColor does not have any effect yet
            Text("Delete").foregroundColor(.red)
            Spacer()
            Image(systemName: "trash").foregroundColor(.red)
        }
    }
}

// MARK: TriggerOverviewView
struct TriggerOverviewView: View {
    
    @ObservedObject var trigger: Trigger<HMTrigger>
    
    @ViewBuilder
    var body: some View {
        WrapperView(edges: .init()) {
            HStack {
                if self.trigger.value is HMEventTrigger {
                    NavigationLink(destination: TriggerDetailView(trigger: Trigger(self.trigger.value as! HMEventTrigger, in: self.trigger.home))) {
                        Image(systemName: "flowchart.fill").font(.headline).foregroundColor(self.iconColor())
                        
                        Text(self.trigger.value.name).foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.secondary).font(Font.system(.footnote))
                    }
                } else if self.trigger.value is HMTimerTrigger {
                    Image(systemName: "clock").font(Font.system(.title)).foregroundColor(self.iconColor())
                    Text(self.trigger.value.name).foregroundColor(.primary)
                    Spacer()
                }
            }
        }
    }
    
    private func iconColor() -> Color {
        self.trigger.value.isEnabled ? .accentColor : .secondary
    }
}

// MARK: TriggerDetailView
struct TriggerDetailView: View {
    
    @EnvironmentObject var home: Home
 
    @ObservedObject var trigger: Trigger<HMEventTrigger>
    
    @State private var showAddEventSheet: Bool = false
    
    @State private var showAddPredicateSheet: Bool = false
    
    @State private var showAddEndEventSheet: Bool = false
    
    var body: some View {
        ScrollView {
            Section {
                HStack {
                    if self.trigger.value.events.isEmpty {
                        Text("Specify when to trigger this automation.").font(.footnote).foregroundColor(.secondary).padding(.bottom)
                    } else if self.trigger.value.actionSets.isEmpty {
                        Text("Specify what to do then.").font(.footnote).foregroundColor(.secondary).padding(.bottom)
                    } else if !self.trigger.value.isEnabled {
                        Text(self.reasonForDisabledState()).font(.footnote).foregroundColor(.secondary).padding(.bottom)
                    }
                    Spacer()
                }
            }.padding(.init(arrayLiteral: .top, .horizontal))
            Section {
                RecurrenceView(trigger: self.trigger.value)
            }.padding(.horizontal)
            Section {
                HStack {
                    Text("When:").bold().font(.system(size: 24))
                    Spacer()
                    Button(action: {
                        self.showAddEventSheet = true
                    }, label: {
                        ZStack {
                            Image(systemName: "plus").foregroundColor(.white)
                        }
                    }).buttonStyle(CircleButtonStyle(color: .accentColor))
                        
                    .sheet(isPresented: self.$showAddEventSheet) {
                        NewEventView(trigger: self.trigger, done: { event in
                            if let ev = event {
                                self.trigger.value.updateEvents(self.trigger.value.events + [ev], completionHandler: { err in
                                    if let e = err {
                                        print(e)
                                    } else {
                                        self.trigger.home(didUpdate: self.trigger.value)
                                        self.showAddEventSheet = false
                                    }
                                })
                            } else {
                                self.showAddEventSheet = false
                            }
                        }).environmentObject(self.home)
                    }
                    
                }.padding(.horizontal)
                if self.trigger.value.events.count > 0 {
                    ForEach(self.trigger.value.events, id: \.uniqueIdentifier) { (event: HMEvent) in
                        WrapperView(edges: .init()) {
                            self.overview(event)
                        }
                        .contextMenu {
                            Button(action: {
                                self.trigger.value.updateEvents(self.trigger.value.events.filter({ e in e != event}), completionHandler: { err in
                                    if let e = err {
                                        print(e)
                                    } else {
                                        withAnimation {
                                            self.trigger.home(didUpdate: self.trigger.value)
                                        }
                                    }
                                })
                            }, label: DeteteContextMenuLabelView.init)
                        }
                        .padding(.init(arrayLiteral: .top, .horizontal))
                    }
                }
            }
            Section {
                HStack {
                    Text("And:").bold().font(.system(size: 24))
                    Spacer()
                    Button(action: {
                        self.showAddPredicateSheet = true
                    }, label: {
                        ZStack {
                            Image(systemName: "plus").foregroundColor(.white)
                        }
                    }).buttonStyle(CircleButtonStyle(color: .accentColor))
                        
                    .sheet(isPresented: self.$showAddPredicateSheet) {
                        NewPredicateView(trigger: self.trigger, done: { predicate in
                            if let pr = predicate {
                                var completePredicate: NSPredicate
                                if let oldP = self.trigger.value.predicate {
                                    if oldP is NSCompoundPredicate && (oldP as! NSCompoundPredicate).compoundPredicateType == .and && !PredicateOverviewView.isComponentValuePredicate(oldP) {
                                        completePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: (oldP as! NSCompoundPredicate).subpredicates.map{e in e as! NSPredicate} + [pr])
                                    } else {
                                        completePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [oldP, pr])
                                    }
                                } else {
                                    completePredicate = pr
                                }
                                
                                self.trigger.value.updatePredicate(completePredicate, completionHandler: { err in
                                    if let e = err {
                                        print(e)
                                    } else {
                                        self.trigger.home(didUpdate: self.trigger.value)
                                        self.showAddPredicateSheet = false
                                    }
                                })
                            } else {
                                self.showAddPredicateSheet = false
                            }
                        }).environmentObject(self.home)
                    }
                    
                }.padding(.init(arrayLiteral: .top, .horizontal))
                if self.trigger.value.predicate != nil {
                    PredicateOverviewView(trigger: self.trigger)
                }
            }
            Section {
                HStack {
                    Text("Then:").bold().font(.system(size: 24))
                    Spacer()
                }.padding(.init(arrayLiteral: .top, .horizontal))
                if self.trigger.value.actionSets.count > 0 {
                    ForEach(self.trigger.value.actionSets, id: \.uniqueIdentifier) { (actionset: HMActionSet) in
                        ActionSetView(actionSet: actionset)
                        .contextMenu {
                            Button(action: {
                                self.trigger.value.removeActionSet(actionset, completionHandler: { err in
                                    if let e = err {
                                        print(e)
                                    } else {
                                        withAnimation {
                                            self.trigger.home(didUpdate: self.trigger.value)
                                        }
                                    }
                                })
                            }, label: DeteteContextMenuLabelView.init)
                        }
                    }
                }
            }
            Section {
                HStack {
                    Text("Until:").bold().font(.system(size: 24))
                    Spacer()
                }.padding(.init(arrayLiteral: .top, .horizontal))
                if self.trigger.value.endEvents.count > 0 {
                    ForEach(self.trigger.value.endEvents, id: \.uniqueIdentifier) { (event: HMEvent) in
                        WrapperView(edges: .init()) {
                            self.overview(event)
                        }
                        .contextMenu {
                            Button(action: {
                                self.trigger.value.updateEvents(self.trigger.value.events.filter({ e in e != event}), completionHandler: { err in
                                    if let e = err {
                                        print(e)
                                    } else {
                                        withAnimation {
                                            self.trigger.home(didUpdate: self.trigger.value)
                                        }
                                    }
                                })
                            }, label: DeteteContextMenuLabelView.init)
                        }
                        .padding(.init(arrayLiteral: .top, .horizontal))
                    }
                }
            }
            .padding(.bottom)
        }
        .navigationBarTitle(self.trigger.value.name)
        
        .navigationBarItems(trailing: Button(action: self.toggleActive, label: {
            ZStack {
                if self.trigger.value.isEnabled {
                    Image(systemName: "pause.fill").foregroundColor(.white)
                } else {
                    Image(systemName: "play.fill").foregroundColor(.white).offset(x: 1.35)
                }
            }
        })
        .disabled(!self.trigger.value.isEnabled && self.trigger.value.events.isEmpty || self.trigger.value.actionSets.isEmpty)
        .buttonStyle(!self.trigger.value.isEnabled && self.trigger.value.events.isEmpty || self.trigger.value.actionSets.isEmpty ? CircleButtonStyle() : CircleButtonStyle(color: .accentColor)))
    }
    
    
    
    @ViewBuilder
    private func overview(_ event: HMEvent) -> some View {
        if event is HMTimeEvent {
            TimeEventOverviewView(event: event as! HMTimeEvent)
        } else if event is HMLocationEvent {
            LocationEventOverviewView(event: event as! HMLocationEvent)
        } else if event is HMPresenceEvent {
            PresenceEventOverviewView(event: event as! HMPresenceEvent)
        } else if event is HMCharacteristicEvent<NSCopying> {
            CharacteristicEventOverviewView(event: CharacteristicEvent(event as! HMCharacteristicEvent<NSCopying>, in: self.trigger.home))
        } else if event is HMCharacteristicThresholdRangeEvent {
            CharacteristicThresholdRangeEventOverviewView(event: CharacteristicEvent(event as! HMCharacteristicThresholdRangeEvent, in: self.trigger.home))
        }
    }
    
    private func toggleActive() {
        self.trigger.value.enable(!self.trigger.value.isEnabled, completionHandler: { err in
            if let e = err {
                print(e)
            } else {
                withAnimation {
                    self.trigger.home(didUpdate: self.trigger.value)
                }
            }
        })
    }
    
    private func reasonForDisabledState() -> String {
        switch self.trigger.value.triggerActivationState {
        case .enabled:
            return "This automation is currently enabled."
        case .disabled:
            return "This automation is currently disabled."
        case .disabledNoHomeHub:
            return "A home hub is required to run automations."
        case .disabledNoCompatibleHomeHub:
            return "The home hub present is not compatible."
        case .disabledNoLocationServicesAuthorization:
            return "This automation requires location services to be enabled."
        default:
            return "Unknown state."
        }
    }
}

// MARK: RecurrenceView
struct RecurrenceView: View {
    let trigger: HMEventTrigger
    
    
    @ViewBuilder
    var body: some View {
        if !self.isNormal() {
            HStack {
                Text(self.description()).multilineTextAlignment(.leading).foregroundColor(.secondary).font(.footnote)
                Spacer()
            }
        }
    }
    
    private func isNormal() -> Bool {
        return !self.trigger.executeOnce && (self.trigger.recurrences == nil || self.isAllWeek())
    }
    
    private func isAllWeek() -> Bool {
        return self.trigger.recurrences != nil && self.trigger.recurrences!.count == Calendar.current.weekdaySymbols.count
    }
    
    func description() -> String {
        var d = ""
        if self.trigger.executeOnce {
            d += "This automation is executed only once."
        }

        if !self.isAllWeek() {
            if self.trigger.executeOnce {
                d += " It "
            } else {
                d += "This automation "
            }
            let days = self.trigger.recurrences!.filter({d in d.weekday != nil}).map({d in d.weekday! - 1}).sorted().map({ day in Calendar.current.shortWeekdaySymbols[day]})
            
            if days.count == 0 {
                d += "is never triggered."
            } else if days.count == 1 {
                d += "is only triggered on " + days[0] + "."
            } else {
                d += "is only triggered on " + days[0..<days.count-1].joined(separator: ", ") + " and " + days[days.count-1] + "."
            }
        }

        return d
    }
}

// MARK: HomeHubStateView
struct HomeHubStateView: View {
    
    let state: HMHomeHubState
    
    @ViewBuilder
    var body: some View {
        Text(self.homeHubStateDescription()).bold().lineLimit(nil)
    }
    
    private func homeHubStateDescription() -> String {
        switch self.state {
        case .connected:
            return "Have your accessories react to changes at home."
        default:
            return "Home hub is not connected. To ensure your automations run as expected, connect a home hub."
        }
    }
    
}
