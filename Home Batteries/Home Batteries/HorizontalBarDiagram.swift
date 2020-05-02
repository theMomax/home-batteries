//
//  HorizontalBarDiagram.swift
//  Home Batteries
//
//  Created by Max Obermeier on 02.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI


struct Segment {
    let name: String?
    @Binding var value: Float
    
    init(_ value: Binding<Float>, name: String? = nil) {
        self._value = value
        self.name = name
    }
}

struct HorizontalBarDiagram: View {
    
    let segments: [Segment]
    let positiveColors: [Color]
    let negativeColors: [Color]
    
    init(_ segments: [Segment], positiveColors: [Color] = HorizontalBarDiagram.positiveColors, negativeColors: [Color] = HorizontalBarDiagram.negativeColors) {
        self.segments = segments
        self.positiveColors = positiveColors
        self.negativeColors = negativeColors
    }
    
    static let positiveColors: [Color] = [.blue, .green, .purple]
    static let negativeColors: [Color] = [.pink, .red, .yellow]
    
    @ViewBuilder
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    ForEach(0..<self.segments.count, id: \.self) { i in
                        BarElement(l: i == 0, r: i == self.segments.count - 1)
                        .foregroundColor(self.colorOf(i))
                            .frame(width: self.relativeWidthOf(i) * geometry.size.width - self.spacingCompensation(2))
                    }
                }
            }
            HStack {
                ForEach(0..<segments.count, id: \.self) { i in
                    Group {
                        if self.segments[i].name != nil {
                            VStack(alignment: .leading) {
                                Text(self.segments[i].name!).foregroundColor(self.colorOf(i))
                                
                                HStack(spacing: 2) {
                                    Text(String(format: "%.0f", self.segments[i].value))
                                    Text("W").foregroundColor(.secondary)
                                }
                            }
                        }
                        if i != self.segments.count - 1 {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    private func spacingCompensation(_ spacing: CGFloat) -> CGFloat {
        return CGFloat(2.0 * (Double(self.segments.count-1)/Double(self.segments.count)))
    }
    
    private func relativeWidthOf(_ segment: Int) -> CGFloat {
        return CGFloat(abs(segments[segment].value) / segments.map({s in abs(s.value)}).reduce(0, +))
    }
    
    private func colorOf(_ segment: Int) -> Color {
        return self.segments[segment].value >= 0 ? self.positiveColors[segment % self.positiveColors.count] : self.negativeColors[segment % self.negativeColors.count]
    }
    
}

struct BarElement: Shape {
    var l: Bool = false
    var r: Bool = false

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height

        // Make sure we do not exceed the size of the rectangle
        let tr = min(self.r ? h/2 : 0, w/2)
        let br = min(self.r ? h/2 : 0, w/2)
        let tl = min(self.l ? h/2 : 0, w/2)
        let bl = min(self.l ? h/2 : 0, w/2)

        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}

struct HorizontalBarDiagram_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            HorizontalBarDiagram([
                Segment(.constant(203.0), name: "L1"),
                Segment(.constant(1009), name: "L2"),
                Segment(.constant(-259), name: "L3")
            ]).padding()
            HorizontalBarDiagram([
                Segment(.constant(1009), name: "L1"),
                Segment(.constant(203.0), name: "L2"),
                Segment(.constant(-259), name: "L3")
            ]).padding()
            HorizontalBarDiagram([
                Segment(.constant(-1009), name: "L1"),
                Segment(.constant(203.0), name: "L2"),
                Segment(.constant(259), name: "L3")
            ]).padding()
        }
    }
}
