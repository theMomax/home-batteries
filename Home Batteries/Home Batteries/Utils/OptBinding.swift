//
//  OptBinding.swift
//  Home Batteries
//
//  Created by Max Obermeier on 04.04.21.
//  Copyright © 2021 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI

@propertyWrapper
struct OptBinding<Value>: DynamicProperty where Value: ExpressibleByNilLiteral {
    private var _binding: Binding<Value>?
    
    var wrappedValue: Value {
        get {
            _binding?.wrappedValue ?? nil
        }
        set {
            _binding?.wrappedValue = newValue
        }
    }
    
    var projectedValue: Binding<Value> {
        _binding ?? .constant(nil)
    }
    
    var present: Bool {
        _binding != nil
    }
    
    init(_ binding: Binding<Value>?) {
        self._binding = binding
    }
}

extension OptBinding: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self.init(nil)
    }
}

extension OptBinding {
    static func constant(_ value: Value) -> OptBinding<Value> {
        OptBinding(.constant(value))
    }
}
