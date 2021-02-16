//
//  OutletDiagramView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 28.10.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import SwiftUI

enum Detail: Int, CustomStringConvertible {
    case day, month, year
    
    var description: String {
        switch self {
        case .day:
            return "Day"
        case .month:
            return "Month"
        case .year:
            return "Year"
        }
    }
    
    static let allCases: [Self] = [.day, .month, .year]
}

enum Distance: Int {
    case this, last
    
    func description(for detail: Detail) -> String {
        switch detail {
        case .day:
            return self == .this ? "Today" : "Yesterday"
        default:
            switch self {
            case .this:
                return "This " + detail.description
            case .last:
                return "Last " + detail.description
            }
        }
    }
    
    static let allCases: [Self] = [.this, .last]
}

struct OutletDiagramView: View {
    
    @ObservedObject var accessory: Accessory
    
    @State var detail: Detail = .day
    
    @State var distance: Distance = .this
       
    init(accessory: Accessory) {
        self.accessory = accessory
        
    }
    
    @ViewBuilder
    var body: some View {
        WrapperView(style: .outset) {
            VStack(spacing: 20) {
                Picker(selection: self.$detail, label:  EmptyView()) {
                    ForEach(Detail.allCases, id: \.self) { c in
                        Text(c.description).tag(c)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Picker(selection: self.$distance, label:  EmptyView()) {
                    ForEach(Distance.allCases, id: \.self) { c in
                        Text(c.description(for: self.detail))
                            .animation(.none)
                            .tag(c)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Group {
                    switch self.detail {
                    case .day:
                        HourlyDiagramView(accessory: self.accessory, distance: self.$distance).animation(.default)
                    case .month:
                        DailyDiagramView(accessory: self.accessory, distance: self.$distance).animation(.default)
                    case .year:
                        MonthlyDiagramView(accessory: self.accessory, distance: self.$distance).animation(.default)
                    }
                }.animation(.linear)
            }
        }
    }
    
}

struct HourlyDiagramView: View {
    
    @ObservedObject var accessory: Accessory
    
    @ObservedObject var hourlyEnergyToday: Characteristic<NSData>
    
    @ObservedObject var hourlyEnergyYesterday: Characteristic<NSData>
    
    @Binding var distance: Distance
       
    init(accessory: Accessory, distance: Binding<Distance>) {
        self.accessory = accessory
        self._distance = distance
        
        if let meter: KoogeekElectricityMeterService = accessory.value.services.typed().first {
            self.hourlyEnergyToday = meter.hourlyToday.observable(updating: false)
            self.hourlyEnergyYesterday = meter.hourlyYesterday.observable(updating: false)
        } else {
            self.hourlyEnergyToday = Characteristic<NSData>()
            self.hourlyEnergyYesterday = Characteristic<NSData>()
        }
        
    }
    
    
    var body: some View {
        if let d = self.data() {
            return AnyView(VStack {
                ColumnChart(of: [d], colors: [.blue])
                HorizontalAxis(tags: HorizontalAxis.hoursOfDay)
                .padding(.bottom)
                Self.stats(data: d)
            })
        } else {
            return AnyView(ActivityIndicator(isAnimating: .constant(true), style: .medium).frame(height: 150))
        }
    }
    
    private func data() -> [Double]? {
        let characteristic = self.distance == .this ? self.hourlyEnergyToday : self.hourlyEnergyYesterday
        if let v = characteristic.value {
            if let d = HourlyEnergyToday.extract(from: v) {
                return d
            }
        }
        return nil
    }
    
    private static func stats(data: [Double]) -> some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 0.0, alignment: .leading), GridItem(.flexible(), spacing: 0.0, alignment: .leading)]) {
                Text("Max: " + HourlyEnergyToday.format(data.max()) + EnergyCapacity.unit()!)
                Text("Tot: " + HourlyEnergyToday.format(data.reduce(0.0, +)) + EnergyCapacity.unit()!)
                Text("Min: " + HourlyEnergyToday.format(data.min()) + EnergyCapacity.unit()!)
                Text("Avg: " + HourlyEnergyToday.format(data.avg()) + EnergyCapacity.unit()!)
            }
            .font(.footnote)
        }
    }
    
}

struct DailyDiagramView: View {
    
    @ObservedObject var accessory: Accessory
    
    @ObservedObject var dailyEnergyThisMonth: Characteristic<NSData>
    
    @ObservedObject var dailyEnergyLastMonth: Characteristic<NSData>
    
    @Binding var distance: Distance
    
    private let daysOfThisMonth = Calendar.current.range(of: .day, in: .month, for: Date())!.upperBound-1
    private let daysOfLastMonth = Calendar.current.range(of: .day, in: .month, for: Calendar.current.date(byAdding: .month, value: -1, to: Date())!)!.upperBound-1
       
    init(accessory: Accessory, distance: Binding<Distance>) {
        self.accessory = accessory
        self._distance = distance
        
        if let meter: KoogeekElectricityMeterService = accessory.value.services.typed().first {
            self.dailyEnergyThisMonth = meter.dailyThisMonth.observable(updating: false)
            self.dailyEnergyLastMonth = meter.dailyLastMonth.observable(updating: false)
        } else {
            self.dailyEnergyThisMonth = Characteristic<NSData>()
            self.dailyEnergyLastMonth = Characteristic<NSData>()
        }
        
    }
    
    
    var body: some View {
        if let d = self.data() {
            return AnyView(
                VStack {
                    ColumnChart(of: [d], colors: [.blue])
                    HorizontalAxis(tags: HorizontalAxis.numbers(from: 1, to: d.count))
                    .padding(.bottom)
                    Self.stats(data: d)
                })
        } else {
            return AnyView(ActivityIndicator(isAnimating: .constant(true), style: .medium).frame(height: 150))
        }
    }
    
    private func data() -> [Double]? {
        let characteristic = self.distance == .this ? self.dailyEnergyThisMonth : self.dailyEnergyLastMonth
        if let v = characteristic.value {
            if let d = DailyEnergyLastMonth.extract(from: v) {
                return d[0..<(self.distance == .this ? self.daysOfThisMonth : self.daysOfLastMonth)].map { $0 }
            }
        }
        return nil
    }
    
    private static func stats(data: [Double]) -> some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 0.0, alignment: .leading), GridItem(.flexible(), spacing: 0.0, alignment: .leading)]) {
                Text("Max: " + DailyEnergyLastMonth.format(data.max()) + EnergyCapacity.unit()!)
                Text("Tot: " + DailyEnergyLastMonth.format(data.reduce(0.0, +)) + EnergyCapacity.unit()!)
                Text("Min: " + DailyEnergyLastMonth.format(data.min()) + EnergyCapacity.unit()!)
                Text("Avg: " + DailyEnergyLastMonth.format(data.avg()) + EnergyCapacity.unit()!)
            }
            .font(.footnote)
        }
    }
    
}

struct MonthlyDiagramView: View {
    
    @ObservedObject var accessory: Accessory
    
    @ObservedObject var monthlyEnergyThisYear: Characteristic<NSData>
    
    @ObservedObject var monthlyEnergyLastYear: Characteristic<NSData>
    
    @Binding var distance: Distance
       
    init(accessory: Accessory, distance: Binding<Distance>) {
        self.accessory = accessory
        self._distance = distance
        
        if let meter: KoogeekElectricityMeterService = accessory.value.services.typed().first {
            self.monthlyEnergyThisYear = meter.monthlyThisYear.observable(updating: false)
            self.monthlyEnergyLastYear = meter.monthlyLastYear.observable(updating: false)
        } else {
            self.monthlyEnergyThisYear = Characteristic<NSData>()
            self.monthlyEnergyLastYear = Characteristic<NSData>()
        }
        
    }
    
    
    var body: some View {
        if let d = self.data() {
            return AnyView(
                VStack {
                    ColumnChart(of: [d], colors: [.blue])
                    HorizontalAxis(tags: HorizontalAxis.monthsOfYear)
                    .padding(.bottom)
                    Self.stats(data: d)
                })
        } else {
            return AnyView(ActivityIndicator(isAnimating: .constant(true), style: .medium).frame(height: 150))
        }
    }
    
    private func data() -> [Double]? {
        let characteristic = self.distance == .this ? self.monthlyEnergyThisYear : self.monthlyEnergyLastYear
        if let v = characteristic.value {
            if let d = MonthlyEnergyLastYear.extract(from: v) {
                return d
            }
        }
        return nil
    }
    
    private static func stats(data: [Double]) -> some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 0.0, alignment: .leading), GridItem(.flexible(), spacing: 0.0, alignment: .leading)]) {
                Text("Max: " + MonthlyEnergyThisYear.format(data.max()) + EnergyCapacity.unit()!)
                Text("Tot: " + MonthlyEnergyThisYear.format(data.reduce(0.0, +)) + EnergyCapacity.unit()!)
                Text("Min: " + MonthlyEnergyThisYear.format(data.min()) + EnergyCapacity.unit()!)
                Text("Avg: " + MonthlyEnergyThisYear.format(data.avg()) + EnergyCapacity.unit()!)
            }
            .font(.footnote)
        }
    }
    
}


extension Array where Array.Element == Double {
    func avg() -> Double? {
        return self.count == 0 ? nil : self.reduce(0.0, +)/Double(self.count)
    }
}
