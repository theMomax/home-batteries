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
    
    @EnvironmentObject var hs: HomeStore
    
    @ViewBuilder
    var body: some View {
        NavigationView {
            if hs.homes.count == 0 {
                NoHomesView()
            } else if hs.homes.count == 1 {
                HomeView(home: hs.homes[0])
            } else {
                HomesOverview()
                .navigationBarTitle(Text("Homes"))
            }
        }
    }
}

struct HomesOverview: View {
    @EnvironmentObject var hs: HomeStore
    
    var body: some View {
        List(self.hs.homes, id: \.home.name) { home in
            NavigationLink(destination: HomeView(home: home)) {
                home.home.isPrimary ? Text(home.home.name).bold() : Text(home.home.name)
            }
        }
    }
}

struct NoHomesView: View {
    var body: some View {
        Text("No homes configured...")
    }
}

struct GlobalView_Previews: PreviewProvider {
    static var previews: some View {
        GlobalView().environmentObject(HomeStore.shared)
    }
}
