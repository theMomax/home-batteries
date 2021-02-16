//
//  QuickViewWidget.swift
//  QuickViewWidget
//
//  Created by Max Obermeier on 15.10.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import HomeKit

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> RenderAccessoryEntry {
        return RenderAccessoryEntry(date: Date(), configuration: SelectAccessoryIntent(), note: "placeholder")
    }

    func getSnapshot(for configuration: SelectAccessoryIntent, in context: Context, completion: @escaping (RenderAccessoryEntry) -> ()) {
        var accessory: HMAccessory? = nil
        var note: String = ""
        var value: CustomStringConvertible?
        
        if let id = configuration.accessory?.identifier {
            let hm = HomeStore.shared.homeManager
            sleep(1)
            
            let accessories = hm.homes.flatMap({ h in h.accessories })
                
            accessory = accessories.filter({ a in a.uniqueIdentifier.uuidString == id }).first
            
            if let a = accessory {
                let c = a.services.first!.characteristics.first!
                c.readValue(completionHandler: {err in
                    if let error = err {
                        note = error.localizedDescription
                    } else {
                        value = (c.value as! CustomStringConvertible)
                        note = "\(c.value)"
                    }
                    
                    let entry = RenderAccessoryEntry(date: Date(), configuration: configuration, note: "getSnapshot \(note)", value: value)
                    
                    completion(entry)
                })
            }
        }

        
    }

    func getTimeline(for configuration: SelectAccessoryIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var accessory: HMAccessory? = nil
        var note: String = ""
        var value: CustomStringConvertible?
        
        if let id = configuration.accessory?.identifier {
            let hm = HomeStore.shared.homeManager
            // take a short nap until the connection to the local HomeKit instance is established (otherwise below code will create an empty array on first call)
            sleep(1)
            
            let accessories = hm.homes.flatMap({ h in h.accessories })
                
            accessory = accessories.filter({ a in a.uniqueIdentifier.uuidString == id }).first
            
            if let a = accessory {
                let s: EnergyStorageService = a.services.typed().first!
                let c: BatteryLevel = s.batteryLevel
                c.characteristic.readValue(completionHandler: {err in
                    if let error = err {
                        note = "\(c.characteristic.uniqueIdentifier): \(error)"
                        print(error)
                    } else {
                        value = (c.characteristic.value as! CustomStringConvertible)
                        note = "\(c.characteristic.value)"
                    }

                    let now = Date()

                    let first = RenderAccessoryEntry(date: now, configuration: configuration, note: "getTimeline (first) \(note)", value: value)
                    let second = RenderAccessoryEntry(date: now.advanced(by: 10), configuration: configuration, note: "getTimeline (second) \(note)", value: value)
                    let third = RenderAccessoryEntry(date: now.advanced(by: 20), configuration: configuration, note: "getTimeline (third) \(note)", value: value)
                    let fourth = RenderAccessoryEntry(date: now.advanced(by: 30), configuration: configuration, note: "getTimeline (fourth) \(note)", value: value)
                    let fifth = RenderAccessoryEntry(date: now.advanced(by: 40), configuration: configuration, note: "getTimeline (fifth) \(note)", value: value)
                    let sixth = RenderAccessoryEntry(date: now.advanced(by: 50), configuration: configuration, note: "getTimeline (sixth) \(note)", value: value)

                    let timeline = Timeline(entries: [first, second, third, fourth, fifth, sixth], policy: .atEnd)
                    completion(timeline)
                })
            }
        }
        
//        let now = Date()
//        
//        let first = RenderAccessoryEntry(date: now, configuration: configuration, note: "getTimeline (first) \(note)", value: value, accessory: accessory)
//        let second = RenderAccessoryEntry(date: now.advanced(by: 10), configuration: configuration, note: "getTimeline (second) \(note)", value: value, accessory: accessory)
//        let third = RenderAccessoryEntry(date: now.advanced(by: 20), configuration: configuration, note: "getTimeline (third) \(note)", value: value, accessory: accessory)
//        let fourth = RenderAccessoryEntry(date: now.advanced(by: 30), configuration: configuration, note: "getTimeline (fourth) \(note)", value: value, accessory: accessory)
//        let fifth = RenderAccessoryEntry(date: now.advanced(by: 40), configuration: configuration, note: "getTimeline (fifth) \(note)", value: value, accessory: accessory)
//        let sixth = RenderAccessoryEntry(date: now.advanced(by: 50), configuration: configuration, note: "getTimeline (sixth) \(note)", value: value, accessory: accessory)
//        
//        let timeline = Timeline(entries: [first, second, third, fourth, fifth, sixth], policy: .atEnd)
//        completion(timeline)
    }
}

struct RenderAccessoryEntry: TimelineEntry {
    let date: Date
    let configuration: SelectAccessoryIntent
    let note: String
    let value: CustomStringConvertible?
    let accessory: HMAccessory?
    
    init(date: Date, configuration: SelectAccessoryIntent, note: String, value: CustomStringConvertible? = nil, accessory: HMAccessory? = nil) {
        self.date = date
        self.configuration = configuration
        self.note = note
        self.value = value
        self.accessory = accessory
    }
}

struct QuickViewWidgetEntryView : View {
    let entry: Provider.Entry
    
    var body: some View {
        if entry.configuration.accessory === nil {
            QuickViewWidgetSampleView(entry: self.entry)
        } else {
            QuickViewWidgetView(entry: self.entry)
        }
    }
}

struct QuickViewWidgetSampleView: View {
    var entry: Provider.Entry

    
    
    var body: some View {
        WrapperView(edges: [], style: .invisible) {
            VStack {
                HStack(alignment: .top) {
                    EnergyStorageServiceQuickView(batteryLevel: .constant(UInt8(90)), chargingState: .constant(ChargingState.charging), statusLowBattery: .constant(StatusLowBattery.normal))
                    .frame(height: 25)
                    ControllerServiceView(state: .constant(StatusFault.noFault))
                }
                Spacer()
                HStack(alignment: .center) {
                    Spacer()
                    ElectricityMeterServiceQuickView(
                        currentPower: .constant(1905),
                        type: ElectricityMeterTypes(rawValue: ElectricityMeterType.excess)!
                    )
                }
                Spacer()
                HStack(alignment: .bottom) {
                    Text("Your Accessory").font(.footnote).bold().lineLimit(1)
                    Spacer()
                }
                HStack {
                    Text("Default Room").font(.footnote).bold().lineLimit(1).foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }
}


struct QuickViewWidgetView: View {
    var entry: Provider.Entry
    
    @State var value: CustomStringConvertible? = nil
    
    @State var note: String = ""
    
    init(entry: Provider.Entry) {
        self.entry = entry
    }
    
    

    var body: some View {
        VStack {
            Text(self.entry.configuration.accessory?.name ?? "nil").font(.caption)
            Text(self.entry.value?.description ?? "nil").font(.caption)
            Text(self.entry.accessory?.name ?? "nil").font(.caption)
            Text(self.entry.note).font(.caption)
            Text(self.value?.description ?? "nil").font(.caption)
            Text(self.note).font(.caption)
            Text(Date(), style: .time).font(.caption)
//            if self.entry.accessory == nil {
//                QuickViewWidgetSampleView(entry: self.entry)
//            } else {
//                self.entry.accessory!.view()
//            }
        }
        .onAppear {
            if let a = entry.accessory {
                let s: EnergyStorageService = a.services.typed().first!
                let c: BatteryLevel = s.batteryLevel
                c.characteristic.readValue(completionHandler: {err in
                    print("heeey")
                    if let error = err {
                        print(error)
                        note = "\(error)"
                    } else {
                        print(c.characteristic.value)
                        value = (c.characteristic.value as! CustomStringConvertible)
                        note = "\(c.characteristic.value)"
                    }
                })
            }
        }
    }
}

@main
struct QuickViewWidget: Widget {
    let kind: String = "themomax.Home-Batteries.QuickViewWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectAccessoryIntent.self, provider: Provider()) { entry in
            QuickViewWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quick View Widget")
        .description("A widget for displaying a quick overview for supported accessories.")
        .supportedFamilies([.systemSmall])
        .onBackgroundURLSessionEvents({ session, completion in
            print("session \(session)")
            completion()
        })
    }
}

struct QuickViewWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuickViewWidgetEntryView(entry: RenderAccessoryEntry(date: Date(), configuration: SelectAccessoryIntent(), note: "preview"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
