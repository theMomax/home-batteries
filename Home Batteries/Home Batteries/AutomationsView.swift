//
//  AutomationsView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 20.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI
import HomeKit

struct AutomationsView: View {

    @ObservedObject var home: Home

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
                                self.home.home(didRemove: trigger)
                            }
                        })
                    }, label: DeteteContextMenuLabelView.init)
                }
                .padding(.init(arrayLiteral: .top, .horizontal))
            }
        }
    }
}

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

struct TriggerOverviewView: View {
    
    @ObservedObject var trigger: Trigger<HMTrigger>
    
    @ViewBuilder
    var body: some View {
        WrapperView(edges: .init()) {
            HStack {
                if self.trigger.value is HMEventTrigger {
                    NavigationLink(destination: TriggerDetailView(trigger: Trigger(self.trigger.value as! HMEventTrigger, in: self.trigger.home))) {
                        Image(systemName: "skew").font(Font.system(.title)).foregroundColor(self.iconColor())
                        Text(self.trigger.value.name).foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.secondary).font(Font.system(.footnote))
                    }
                } else {
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

struct TriggerDetailView: View {
 
    @ObservedObject var trigger: Trigger<HMEventTrigger>
    
    
    var body: some View {
        ScrollView {
            if self.trigger.value.events.count > 0 {
                Section {
                    HStack {
                        Text("When:").bold().font(.system(size: 24))
                        Spacer()
                    }.padding(.init(arrayLiteral: .horizontal, .top))
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
                                        self.trigger.home(didUpdate: self.trigger.value)
                                    }
                                })
                            }, label: DeteteContextMenuLabelView.init)
                        }
                        .padding(.init(arrayLiteral: .top, .horizontal))
                    }
                }
            }
            if self.trigger.value.predicate != nil {
                Section {
                    HStack {
                        Text("And:").bold().font(.system(size: 24))
                        Spacer()
                    }.padding(.init(arrayLiteral: .horizontal, .top))
                    PredicateOverviewView(trigger: self.trigger)
                }
            }
            if self.trigger.value.actionSets.count > 0 {
                Section {
                    HStack {
                        Text("Then:").bold().font(.system(size: 24))
                        Spacer()
                    }.padding(.init(arrayLiteral: .horizontal, .top))
                    ForEach(self.trigger.value.actionSets, id: \.uniqueIdentifier) { (actionset: HMActionSet) in
                        WrapperView(edges: .init()) {
                            HStack {
                                Image(systemName: "gear").font(.title)
                                Text(actionset.name)
                                Spacer()
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                self.trigger.value.removeActionSet(actionset, completionHandler: { err in
                                    if let e = err {
                                        print(e)
                                    } else {
                                        self.trigger.home(didUpdate: self.trigger.value)
                                    }
                                })
                            }, label: DeteteContextMenuLabelView.init)
                        }
                        .padding(.init(arrayLiteral: .top, .horizontal))
                    }
                }
            }
            if self.trigger.value.endEvents.count > 0 {
                Section {
                    HStack {
                        Text("Until:").bold().font(.system(size: 24))
                        Spacer()
                    }.padding(.init(arrayLiteral: .horizontal, .top))
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
                                        self.trigger.home(didUpdate: self.trigger.value)
                                    }
                                })
                            }, label: DeteteContextMenuLabelView.init)
                        }
                        .padding(.init(arrayLiteral: .top, .horizontal))
                    }
                }
            }
            HStack{EmptyView()}.padding()
        }
        .navigationBarTitle(self.trigger.value.name)
    }
    
    @ViewBuilder
    private func overview(_ event: HMEvent) -> some View {
        if event is HMTimeEvent {
            TimeEventOverviewView(event: event as! HMTimeEvent)
        } else if event is HMLocationEvent {
            LocationEventOverviewView(event: event as! HMLocationEvent)
        } else if event is HMPresenceEvent {
            PresenceEventOverviewView(event: event as! HMPresenceEvent)
        } else {
            CharacteristicEventOverviewView(event: CharacteristicEvent(event as! HMCharacteristicEvent<NSCopying>, in: self.trigger.home))
        }
    }
}

struct PresenceEventOverviewView: View {
    
    let event: HMPresenceEvent
    
    var body: some View {
        HStack {
            Image(systemName: "person").font(.title).foregroundColor(.primary)
            Text("???")
            Spacer()
        }
    }
}

struct LocationEventOverviewView: View {
    
    let event: HMLocationEvent
    
    var body: some View {
        HStack {
            Image(systemName: "location").font(.title).foregroundColor(.primary)
            Text("???")
            Spacer()
        }
    }
}

struct TimeEventOverviewView: View {
    
    let event: HMTimeEvent
    
    var body: some View {
        HStack {
            Image(systemName: "clock").font(.title).foregroundColor(.primary)
            Text("???")
            Spacer()
        }
    }
}

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
