//
//  ActionSetView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 09.07.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import HomeKit
import SwiftUI

struct ActionSetView: View {
    
    let actionSet: HMActionSet
    let actions: [HMAction]
    
    init(actionSet: HMActionSet) {
        self.actionSet = actionSet
        self.actions = Array(actionSet.actions)
    }
    
    var body: some View {
        WrapperView {
            VStack {
                ForEach(self.actions.indices) { i in
                    ActionView(action: self.actions[i])
                    if i < self.actions.count-1 {
                        Divider()
                    }
                }
            }
        }
    }
    
}

struct ActionView: View {
    let action: HMAction
    
    var body: some View {
        HStack {
            Image(systemName: "gear").font(.headline)
            Text(self.description())
            Spacer()
        }
    }
    
    private func description() -> String {
        switch self.action {
        case let a as HMCharacteristicWriteAction<NSCopying>:
            if let c = a.characteristic.known() {
                return c.updateDescription(a.targetValue)
            } else {
                return "Unknown value is changed"
            }
        default:
            return "Unknown action"
        }
    }
}
