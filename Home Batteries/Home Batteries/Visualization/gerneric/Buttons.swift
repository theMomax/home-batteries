//
//  Buttons.swift
//  Home Batteries
//
//  Created by Max Obermeier on 24.09.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI

struct CircleButtonStyle: ButtonStyle {
    
    let color: Color
    
    init(color: Color = .init(.sRGB, white: 0.5, opacity: 0.5)) {
        self.color = color
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.padding(8).background(Circle().fill(self.color))

    }
}

struct SecondaryCircleButton<Button: View>: View {
    
    let button: Button
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        self.button.buttonStyle(CircleButtonStyle(color: Color(.secondarySystemFill)))
    }
}

extension View {
    public func secondaryCircleButtonStyle() -> some View {
        SecondaryCircleButton(button: self)
    }
}

struct CloseButton: View {
    
    let action: () -> ()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: self.action, label: {
            Image(systemName: "plus").rotationEffect(Angle(degrees: 45)).foregroundColor(.gray).scaleEffect(1.2)
        }).secondaryCircleButtonStyle()
    }
}
