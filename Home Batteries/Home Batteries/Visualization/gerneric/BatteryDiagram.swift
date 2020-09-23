//
//  BatteryDiagram.swift
//  Home Batteries
//
//  Created by Max Obermeier on 03.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI

struct BatteryDiagram: View {
    @Binding var batteryLevel: UInt8?
    @Binding var chargingState: UInt8?
    @Binding var statusLowBattery: UInt8?
    
    @ViewBuilder
    var body: some View {
        ZStack() {
            BatteryBox()
            BatteryFill(percentage: Float(batteryLevel ?? 0) / 100.0).foregroundColor(chargingState == 1 ? .green : statusLowBattery == 1 ? .red : .primary)
        }
        .aspectRatio(2.04, contentMode: .fit)
    }
}

struct BatteryFill: Shape {
    
    var percentage: Float
    
    func path(in rect: CGRect) -> Path {
        var box = Path()

        let w = min(rect.size.width, rect.size.height * 2.04)
        let h = min(rect.size.height, rect.size.width / 2.04)

        let xoff = ((rect.size.width - w) / 2)
        let yoff = ((rect.size.height - h) / 2)
        
        let bw = w * 0.89
        let cr = h/5
        let os = h/20
        
        let crinner = cr/2
        let osinner = os * 4
            
            
        box = Path(roundedRect: CGRect(x: xoff + osinner, y: yoff + osinner, width: (bw-2*osinner) * CGFloat(percentage), height: h-2*osinner), cornerRadius: crinner)
        
        return box
    }
}

struct BatteryBox: Shape {

    func path(in rect: CGRect) -> Path {
        var box = Path()

        let w = min(rect.size.width, rect.size.height * 2.04)
        let h = min(rect.size.height, rect.size.width / 2.04)
        
        let xoff = ((rect.size.width - w) / 2)
        let yoff = ((rect.size.height - h) / 2)

        let bw = w * 0.89
        let cr = h/5
        let os = h/20
            
            
        box.move(to: CGPoint(x: xoff + bw / 2.0, y: yoff + os))
        box.addLine(to: CGPoint(x: xoff + bw - cr - os, y: yoff + os))
        box.addArc(center: CGPoint(x: xoff + bw - cr - os, y: yoff + cr + os), radius: cr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        box.addLine(to: CGPoint(x: xoff + bw - os, y: yoff + h - cr - os))
        box.addArc(center: CGPoint(x: xoff + bw - cr - os, y: yoff + h - cr - os), radius: cr,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        box.addLine(to: CGPoint(x: xoff + cr + os, y: yoff + h - os))
        box.addArc(center: CGPoint(x: xoff + cr + os, y: yoff + h - cr - os), radius: cr,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        box.addLine(to: CGPoint(x: xoff + os, y: yoff + cr + os))
        box.addArc(center: CGPoint(x: xoff + cr + os, y: yoff + cr + os), radius: cr,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        
        box.closeSubpath()

        box = box.strokedPath(StrokeStyle.init(lineWidth: h/10, lineCap: .butt, lineJoin: .miter, miterLimit: 0, dash: [], dashPhase: 0))
        
        let tipcr = 0.9 * cr
        
        var tip = Path()
        
        tip.addArc(center: CGPoint(x: xoff + w - 1.08 * tipcr, y: yoff + h/2), radius: tipcr,
        startAngle: Angle(degrees: -70), endAngle: Angle(degrees: 70), clockwise: false)
        
        tip.closeSubpath()
        
        box.addPath(tip)
        
        return box
    }
}


struct BatteryDiagram_Previews: PreviewProvider {
        
    static var previews: some View {
        ScrollView {
            WrapperView {
                HStack {
                    BatteryDiagram(batteryLevel: .constant(UInt8(80)), chargingState: .constant(UInt8(1)), statusLowBattery: .constant(UInt8(0)))
                }
            }
            
            WrapperView {
                HStack {
                    BatteryBox()
                    Image(systemName: "battery.100").font(Font.system(.largeTitle))
                }
            }
            
            WrapperView {
                HStack {
                    BatteryDiagram(batteryLevel: .constant(UInt8(80)), chargingState: .constant(UInt8(1)), statusLowBattery: .constant(UInt8(0)))
                    Image(systemName: "battery.100").font(Font.system(.largeTitle))
                }
            }
        }
    }
}
