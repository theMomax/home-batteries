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
        NavigationView {
            if hm.value.homes.count == 0 {
                NoHomesView()
            } else if hm.value.homes.count == 1 {
                HomeView(home: Home(hm.value.homes[0]))
            } else {
                HomesOverview()
                .navigationBarTitle(Text("Homes"))
            }
        }
    }
}

struct HomesOverview: View {
    @EnvironmentObject var hm: HomeManger
    
    var body: some View {
        List(self.hm.value.homes, id: \.name) { home in
            NavigationLink(destination: HomeView(home: Home(home))) {
                home.isPrimary ? Text(home.name).bold() : Text(home.name)
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
        GlobalView().environmentObject(HomeManger())
    }
}
