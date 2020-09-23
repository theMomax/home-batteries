//
//  ConnectingView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 05.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI
import HomeKit

let TIMEOUT = DispatchTimeInterval.seconds(2)

struct ConnectingToHomeKitView: View {
    
    @State var timeoutPassed: Bool = false
    
    @ObservedObject var hm: HomeKitManager = HomeKitManager()
    
    var body: some View {
        timeout()
        return VStack(alignment: .center, spacing: 20) {
            if !hm.value.authorizationStatus.contains(.authorized) {
                Text("This app requires access to your home data to display and edit home battery related accessories and automations.").foregroundColor(.secondary).multilineTextAlignment(.center).padding()
            } else if !self.timeoutPassed {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
                Text("Connecting to HomeKit...").foregroundColor(.secondary)
            } else {
                Text("You're homeless :(").foregroundColor(.secondary).multilineTextAlignment(.center).padding()
            }
        }
    }
    
    func timeout() {
        DispatchQueue.main.asyncAfter(deadline: .now() + TIMEOUT) {
            self.timeoutPassed = true
        }
    }
}

struct ConnectingToAccessoryView: View {
    
    @Binding var accessory: HMAccessory
    
    @State var timeoutPassed: Bool = false
    
    
    var body: some View {
        timeout()
        return VStack(alignment: .center, spacing: 20) {
            if !self.timeoutPassed {
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
                Text("Connecting to accessory \(accessory.name)...").foregroundColor(.secondary)
            } else {
                Image(systemName: "exclamationmark.circle")
                    .font(Font.system(.title))
                    .foregroundColor(.orange)
                    .padding(.top)
                Text("Connecting to accessory \(accessory.name) failed!").foregroundColor(.secondary)
            }
        }
    }
    
    func timeout() {
        DispatchQueue.main.asyncAfter(deadline: .now() + TIMEOUT) {
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
