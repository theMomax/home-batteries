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

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> RenderAccessoryEntry {
        return RenderAccessoryEntry(date: Date(), configuration: SelectAccessoryIntent())
    }

    func getSnapshot(for configuration: SelectAccessoryIntent, in context: Context, completion: @escaping (RenderAccessoryEntry) -> ()) {
        let entry = RenderAccessoryEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: SelectAccessoryIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let now = Date()
        let next = now.advanced(by: 10)
        
        let first = RenderAccessoryEntry(date: now, configuration: configuration)
        let second = RenderAccessoryEntry(date: next, configuration: configuration)
        
        let timeline = Timeline(entries: [first, second], policy: .atEnd)
        completion(timeline)
    }
}

struct RenderAccessoryEntry: TimelineEntry {
    let date: Date
    let configuration: SelectAccessoryIntent
}

struct QuickViewWidgetEntryView : View {
    var entry: Provider.Entry

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
        }.padding()
    }
}


struct QuickViewWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
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
    }
}

struct QuickViewWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuickViewWidgetEntryView(entry: RenderAccessoryEntry(date: Date(), configuration: SelectAccessoryIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
