//
//  Charts.swift
//  Home Batteries
//
//  Created by Max Obermeier on 28.10.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI
import Charts

extension Array where Array.Element == Double {
    
    func normalized() -> Self {
        if let min = self.min() {
            if let max = self.max() {
                return self.map( { e in (e-min)/(max != min ? max-min : 1) })
            }
        }
        return self
    }
    
    func normalized(to min: Double, and max: Double) -> Self {
        return self.map( { e in (e-min)/(max != min ? max-min : 1) })
    }
}

extension Array where Array.Element == Array<Double> {
    
    func normalized() -> Self {
        let sizes = self.map({ a in a.count })
        
        let allNormalized: [Double] = self.reduce([], +).normalized()
        var normalized: [[Double]] = []
        var next = 0
        for s in sizes {
            normalized.append(allNormalized[next..<next+s].map({ $0 }))
            next += s
        }
        return normalized
    }
    
    func trimmed() -> Self {
        if let minSize = self.map({a in a.count}).min() {
            return self.map({ a in a[..<minSize].map({ $0 }) })
        }
        return self
    }
    
    func normalized(to min: Double, and max: Double) -> Self {
        return self.map { a in a.normalized(to: min, and: max)}
    }
}

struct LineChart: View {
    
    let normalized: [[Double]]
    let colors: [Color]
    let height: CGFloat
    
    init(of data: [[Double]], trim: Bool = true, normalize: Bool = true, colors: [Color] = [.primary, .purple, .blue, .green], height: CGFloat = 150) {
        self.colors = colors
        self.height = height
        
        let trimmed = trim ? data.trimmed() : data
        
        let normalized = normalize ? trimmed.normalized() : trimmed
        self.normalized = normalized
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
            ForEach(self.normalized.indices) { index in
                Chart(data: self.normalized[index])
                    .chartStyle(
                        LineChartStyle(.quadCurve, lineColor: self.colors[index % self.colors.count], lineWidth: 2)
                    )
            }
        }
        .frame(height: self.height)
    }
    
}

struct ColumnChart: View {
    
    let normalized: [[Double]]
    let colors: [Color]
    let height: CGFloat
    
    init(of data: [[Double]], trim: Bool = true, normalize: Bool = true, colors: [Color] = [.primary, .purple, .blue, .green], height: CGFloat = 150) {
        self.colors = colors
        self.height = height
        
        let trimmed = trim ? data.trimmed() : data
        
        let normalized = normalize ? trimmed.normalized() : trimmed
        self.normalized = normalized.map{ a in a.reversed() }
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
            ForEach(self.normalized.indices) { index in
                Chart(data: self.normalized[index])
                    .chartStyle(
                        ColumnChartStyle(column: Capsule().foregroundColor(self.colors[index % self.colors.count]), spacing: 2)
                    )
            }
        }
        .frame(height: self.height)
    }
    
}

struct HorizontalAxis: View {
    let tags: [CustomStringConvertible]
    
    let itemSize: CGFloat
    let totalWidth: CGFloat
    
    init(tags: [CustomStringConvertible]) {
        self.tags = tags
        let w = tags.map({ s in CGFloat(s.description.count * 10) }).max() ?? CGFloat(1)
        self.totalWidth = CGFloat(tags.count) * w
        self.itemSize = w
    }
    
    var body: some View {
        Divider()
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(self.tags.indices, id: \.self) { tagIndex in
                    self.item(on: tagIndex, width: geo.size.width)
                }
            }
        }
        .lineLimit(1)
        .font(.caption2)
        .foregroundColor(.secondary)
        .allowsTightening(false)
    }
    
    private func priority(of index: Int) -> Double {
        return [2, 4, 8, 16, 32, 64, 128].map({ (i: Int) -> Double in
            if index % i == 0 {
                return 1.0
            } else {
                return 0.0
            }
        }).reduce(0.0, +)
    }
    
    @ViewBuilder
    private func item(on index: Int, width: CGFloat) -> some View {
        if self.priority(of: index)+1 >= Double(self.totalWidth/width) {
            Text(self.tags[index].description)
                .frame(width: max(self.itemSize, width / CGFloat(self.tags.count)), alignment: Alignment(horizontal: self.itemSize > width / CGFloat(self.tags.count) ? .leading : .center, vertical: .center))
        } else {
            Spacer(minLength: 0)
        }
    }
    
    static let hoursOfDay: [String] = Self.numbers(from: 0, to: 23)
    
    static let monthsOfYear: [String] = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
    
    static func numbers(from: Int, to: Int) -> [String] {
        var labels: [String] = []
        for i in from...to {
            labels.append(String(i))
        }
        return labels
     }
    
}


struct SingleChart_Preview: PreviewProvider {
    
    static private let data: [Double] = [0.1, 0.3, 0.2, 0.5, 0.4, 1.9, 0.1, 0.1, 0.3, 0.2, 0.5, 0.4, 2.9, 0.1, 0.1, 0.3, 0.2, 0.5, 0.4, 2.9, 0.1, 0.1, 0.3, 0.2]
    
    static var previews: some View {
        Group {
            WrapperView(style: .outset) {
                LineChart(of: [Self.data, Self.data.map( { -$0 })])
            }
            ScrollView {
                WrapperView(style: .outset) {
                    VStack {
                        ColumnChart(of: [Self.data, Self.data.map( { 0.5 * $0 })])

                        HorizontalAxis(tags: HorizontalAxis.hoursOfDay)
                    }
                }
                WrapperView(style: .outset) {
                    VStack {
                        ColumnChart(of: [Self.data[..<12].map{ $0 }, Self.data[..<12].map( { 0.5 * $0 })])

                        HorizontalAxis(tags: HorizontalAxis.monthsOfYear)
                    }
                }
            }

        }.background(Color.tintedBackground).edgesIgnoringSafeArea(.bottom)
    }
}
