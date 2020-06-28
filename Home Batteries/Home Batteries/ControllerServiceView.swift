//
//  ControllerServiceView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 01.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI
import HomeKit

struct ControllerServiceView: View {
    
    static let supportedServices = [ControllerService.self]
    
    @Binding var state: UInt8?
    
    var body: some View {
        StateView(state: self.$state)
    }
}

struct StateView: View {
    
    @Binding var state: UInt8?
    
    var body: some View {
        HStack {
            Spacer(minLength: 0)
            Text(StateView.label(state).uppercased()).lineLimit(1).font(Font.system(.footnote)).layoutPriority(1)
            Circle().frame(width: 15.0, height: 15.0)
        }
        .foregroundColor(StateView.color(state))
    }
    
    static func label(_ state: UInt8?) -> String {
        switch state {
        case 0:
            return "ok"
        case 1:
            return "error"
        default:
            return "unknown"
        }
    }
    
    static func color(_ state: UInt8?) -> Color {
        switch state {
        case 0:
            return .green
        case 1:
            return .red
        default:
            return .secondary
        }
    }
}


struct ControllerServiceView_Previews: PreviewProvider {
        
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(UInt8(0)..<UInt8(3), id: \.self) { state in
                ZStack {
                    Color(.systemBackground).edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        WrapperView {
                            ControllerServiceView(state: .constant(state))
                        }
                    }
                }
                
                
                .previewDisplayName("\(colorScheme) -> \(StateView.label(state))")
            }
            .environment(\.colorScheme, colorScheme)
        }
    }
}
