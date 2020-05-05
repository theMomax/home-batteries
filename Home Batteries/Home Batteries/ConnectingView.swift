//
//  ConnectingView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 05.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI


struct ConnectingToHomeKitView: View {
    
    @State var timeoutPassed: Bool = false
    
    var body: some View {
        timeout()
        return VStack(alignment: .center, spacing: 20) {
            if !self.timeoutPassed {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
                Text("Connecting to HomeKit...").foregroundColor(.secondary)
            } else {
                Text("No homes detected!")
            }
        }
    }
    
    func timeout() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.timeoutPassed = true
        }
    }
}

struct ConnectingToAccessoryView: View {
    
    @ObservedObject var accessory: Accessory
    
    @State var timeoutPassed: Bool = false
    
    
    var body: some View {
        timeout()
        return VStack(alignment: .center, spacing: 20) {
            if !self.timeoutPassed {
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
                Text("Connecting to accessory \(accessory.value.name)...").foregroundColor(.secondary)
            } else {
                Image(systemName: "exclamationmark.triangle")
                    .font(Font.system(.title))
                    .foregroundColor(.orange)
                    .padding(.top)
                Text("Connecting to accessory \(accessory.value.name) failed!").foregroundColor(.secondary)
            }
        }
    }
    
    func timeout() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.timeoutPassed = true
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

