//
//  AccessoriesView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 01.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI
import HomeKit

struct AccessoriesView: View {
    
    let accessories: [HMAccessory]
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ForEach(accessories, id: \.uniqueIdentifier) { accessory in
                ZStack {
                    Text(accessory.name)
                }
            }
        }
    }
}

struct AccessoriesView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
