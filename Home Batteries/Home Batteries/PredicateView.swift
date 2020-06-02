//
//  PredicateView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 23.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI
import HomeKit

struct PredicateOverviewView: View {
    
    @ObservedObject var trigger: Trigger<HMEventTrigger>
    
    @ViewBuilder
    var body: some View {
        if self.trigger.value.predicate == nil {
            EmptyView()
        } else {
            self.visalization(self.trigger.value.predicate!, isTopLevel: true)
        }
    }
    
    @ViewBuilder
    func visalization(_ predicate: NSPredicate, isTopLevel: Bool = false) -> some View {
        if predicate is NSCompoundPredicate && (predicate as! NSCompoundPredicate).compoundPredicateType == .and && !Self.isComponentValuePredicate(predicate) {
            ForEach((predicate as! NSCompoundPredicate).subpredicates.map({sp in sp as! NSPredicate}), id: \.predicateFormat) { sp in
                WrapperView(edges: .init()) {
                    HStack {
                        if Self.isComponentValuePredicate(sp ) {
                            Image(systemName: "skew").font(.headline).foregroundColor(.accentColor)
                        } else {
                            Image(systemName: "questionmark").font(.headline)
                        }
                        Text(Self.description(sp)).fixedSize(horizontal: false, vertical: true).foregroundColor(.primary)
                        Spacer()
                    }
                }
                .contextMenu {
                    Button(action: {
                        self.trigger.value.updatePredicate(Self.removeSubpredicate(sp, from: predicate as! NSCompoundPredicate), completionHandler: { err in
                            if let e = err {
                                print(e)
                            } else {
                                withAnimation {
                                    self.trigger.home(didUpdate: self.trigger.value)
                                }
                            }
                        })
                    }, label: DeteteContextMenuLabelView.init)
                }
                .padding(.init(arrayLiteral: .top, .horizontal))
            }
        } else {
            WrapperView(edges: .init()) {
                HStack {
                    Image(systemName: "questionmark").font(.headline)
                    Text(Self.description(predicate)).fixedSize(horizontal: false, vertical: true).foregroundColor(.primary)
                    Spacer()
                }
            }
            .contextMenu {
                Button(action: {
                    self.trigger.value.updatePredicate(nil, completionHandler: { err in
                        if let e = err {
                            print(e)
                        } else {
                            withAnimation {
                                self.trigger.home(didUpdate: self.trigger.value)
                            }
                        }
                    })
                }, label: DeteteContextMenuLabelView.init)
            }
            .padding(.init(arrayLiteral: .top, .horizontal))
        }
    }
    
    static func description(_ predicate: NSPredicate) -> String {
        var d = predicateDescription(predicate)
        if d.hasPrefix("(") {
            d = String(d.dropFirst())
        }
        if d.hasSuffix(")") {
            d = String(d.dropLast())
        }
        return d
    }
    
    private static func removeSubpredicate(_ remove: NSPredicate, from predicate: NSCompoundPredicate) -> NSCompoundPredicate {
        var newSubpredicates = predicate.subpredicates
        newSubpredicates.removeAll(where: { sp in (sp as! NSPredicate) == remove})
        return NSCompoundPredicate(type: predicate.compoundPredicateType, subpredicates: newSubpredicates.map({sp in sp as! NSPredicate}))
    }
    
    private static func predicateDescription(_ predicate: NSPredicate) -> String {
        switch predicate {
        case let p as NSComparisonPredicate:
            return expressionDescription(p.leftExpression) + " " + modifierDescription(p.comparisonPredicateModifier) + " " + operatorDescription(p.predicateOperatorType) + " " + expressionDescription(p.rightExpression)
        case let p as NSCompoundPredicate:
            // custom case: characteristic is equal to <Characteristic Description> and characteristicValue <Some Comparison> to <Some Value>
            // in this case we just say: <Characteristic Description> <Some Comparison> to <Some Value>
            if Self.isComponentValuePredicate(p) {
                let lhs = p.subpredicates[0] as! NSComparisonPredicate
                let rhs = p.subpredicates[1] as! NSComparisonPredicate
                let characteristic = lhs.rightExpression.constantValue as! HMCharacteristic
                return predicateDescription(NSComparisonPredicate(leftExpression: lhs.rightExpression, rightExpression: rhs.rightExpression, modifier: rhs.comparisonPredicateModifier, type: rhs.predicateOperatorType, options: rhs.options)) + CurrentPower.unit(characteristic)
            }
            
            return "(" +
                (p.compoundPredicateType == .not ?
                    compoundTypeDescription(.not) + " " + predicateDescription(p.subpredicates[0] as! NSPredicate) :
                    p.subpredicates.map({sp in predicateDescription(sp as! NSPredicate)}).joined(separator: " " + compoundTypeDescription(p.compoundPredicateType) + " ")
                ) + ")"
        default:
            return "unknown"
        }
    }
    
    private static func isComponentValuePredicate(_ predicate: NSPredicate) -> Bool {
        if let p = predicate as? NSCompoundPredicate {
            if p.subpredicates.count == 2 && p.compoundPredicateType == .and && p.subpredicates[0] is NSComparisonPredicate &&  p.subpredicates[1] is NSComparisonPredicate {
                let lhs = p.subpredicates[0] as! NSComparisonPredicate
                let rhs = p.subpredicates[1] as! NSComparisonPredicate
                if lhs.comparisonPredicateModifier == .direct && lhs.predicateOperatorType == .equalTo && lhs.leftExpression.expressionType == .keyPath && lhs.leftExpression.keyPath == "characteristic" {
                    if rhs.leftExpression.expressionType == .keyPath && rhs.leftExpression.keyPath == "characteristicValue" {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private static func compoundTypeDescription(_ type: NSCompoundPredicate.LogicalType) -> String {
        switch type {
        case .and:
            return "and"
        case .or:
            return "or"
        case .not:
            return "not"
        @unknown default:
            return "somehow compounded"
        }
    }
    
    private static func expressionDescription(_ e: NSExpression) -> String {
        switch e.expressionType {
        case .constantValue:
            switch e.constantValue! {
            case let v as NSDateComponents:
                return String(v.hour) + ":" + String(v.minute)
            case let v as HMCharacteristic:
                return CurrentPower.description(v)
            case let v as CustomStringConvertible:
                return v.description
            default:
                return "some constant"
            }
        case .function:
            switch e.function {
            case "now":
                return "current time"
            default:
                return e.description
            }
        default:
            return e.description
        }
    }
    
    private static func modifierDescription(_ modifier: NSComparisonPredicate.Modifier) -> String {
        switch modifier {
        case .direct:
            return "is"
        case .all:
            return "are"
        case .any:
            return "one is"
        @unknown default:
            return "is somehow"
        }
    }
    
    private static func operatorDescription(_ op: NSComparisonPredicate.Operator) -> String {
        switch op {
        case .lessThan:
            return "less than"
        case .lessThanOrEqualTo:
            return "less than or equal to"
        case .greaterThan:
            return "greater than"
        case .greaterThanOrEqualTo:
            return "greater than or equal to"
        case .equalTo:
            return "equal to"
        case .notEqualTo:
            return "not equal to"
        case .matches:
            return "matching"
        case .like:
            return "like"
        case .beginsWith:
            return "beginning with"
        case .endsWith:
            return "ending with"
        case .in:
            return "in"
        case .contains:
            return "containing"
        case .between:
            return "between"
        default:
            return "somehow comparing to"
        }
    }
}
