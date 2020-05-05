//
//  AggregatedValue.swift
//  Home Batteries
//
//  Created by Max Obermeier on 05.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import Combine

/// - Tag: AggregatedValue
class AggregatedValue<T>: NSObject, ObservableObject, Subscriber {
    
    typealias Input = T?
    
    typealias Failure = Never
    
    
    private let aggregate: (_ result: T?, _ value: T?) -> T?
    
    private var subscription: Subscription?
    
    @Published var value: T?
    
    init(using aggregator: @escaping (_ result: T?, _ value: T?) -> T? ,_ characteristics: Characteristic<T>...) {
        self.value = nil
        self.aggregate = aggregator
        
        super.init()
        
        for c in characteristics {
            c.$value.receive(subscriber: self)
        }
    }
    
    deinit {
        if let s = self.subscription {
            s.cancel()
        }
    }
    
    func receive(subscription: Subscription) {
        self.subscription = subscription
    }
    
    func receive(_ input: T?) -> Subscribers.Demand {
        self.value = self.aggregate(self.value, input)
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("AggregatedValue received Failure")
    }
    
}

