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
    
    static let supportedServices = ["00000001-0000-1000-8000-0036AC324978"]
    
    @Binding var state: UInt8?
    
    var body: some View {
        StateView(state: self.$state)
    }
}

struct StateView: View {
    
    @Binding var state: UInt8?
    
    var body: some View {
        HStack {
            Spacer()
            Text(StateView.label(state).uppercased()).font(Font.system(.footnote))
            Circle().scale(0.75).frame(maxWidth: 20.0)
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
                        AccessoryWrapperView {
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
