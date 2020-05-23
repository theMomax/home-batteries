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
            }
        }
    }
}

struct TriggerOverviewView: View {
    
    @ObservedObject var trigger: Trigger<HMTrigger>
    
    @ViewBuilder
    var body: some View {
        WrapperView {
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
                        WrapperView {
                            self.overview(event)
                        }
                    }
                }
            }
            if self.trigger.value.predicate != nil {
                Section {
                    HStack {
                        Text("And:").bold().font(.system(size: 24))
                        Spacer()
                    }.padding(.init(arrayLiteral: .horizontal, .top))
                    WrapperView {
                        PredicateOverviewView(trigger: self.trigger)
                    }
                }
            }
            if self.trigger.value.actionSets.count > 0 {
                Section {
                    HStack {
                        Text("Then:").bold().font(.system(size: 24))
                        Spacer()
                    }.padding(.init(arrayLiteral: .horizontal, .top))
                    ForEach(self.trigger.value.actionSets, id: \.uniqueIdentifier) { (actionset: HMActionSet) in
                        WrapperView {
                            HStack {
                                Image(systemName: "gear").font(.title)
                                Text(actionset.name)
                                Spacer()
                            }
                        }
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
                        WrapperView {
                            self.overview(event)
                        }
                    }
                }
            }
            EmptyView().padding()
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
