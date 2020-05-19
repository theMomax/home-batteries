//
//  GlobalView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 29.04.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI

struct GlobalView: View {
    
    @EnvironmentObject var hm: HomeManger
    
    @ViewBuilder
    var body: some View {
        if self.hm.value.homes.count == 0 {
            ConnectingToHomeKitView()
        } else {
            HomeView()
        }
    }
    
    
}

struct NoHomesView: View {
    var body: some View {
        Text("No homes detected...")
    }
}
