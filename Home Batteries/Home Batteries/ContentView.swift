//
//  ContentView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 28.04.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI
import HomeKit

struct ContentView: View {
    var body: some View {
        GlobalView().environmentObject(HomeManger())
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
