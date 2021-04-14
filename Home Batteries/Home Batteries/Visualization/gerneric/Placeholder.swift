//
//  Placeholder.swift
//  Home Batteries
//
//  Created by Max Obermeier on 16.02.21.
//  Copyright © 2021 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func asPlaceholder<T>(nil activeIfNil: T?) -> some View {
        return self.asPlaceholder(activeIfNil == nil)
    }
    
    @ViewBuilder
    func asPlaceholder(_ active: Bool) -> some View {
        if active {
            self.redacted(reason: .placeholder)
        } else {
            self
        }
    }
}
