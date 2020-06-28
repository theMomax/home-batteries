//
//  PredicateView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 23.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI
import HomeKit


// MARK: PredicateOverviewView
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
                        if Self.isComponentValuePredicate(sp) {
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
                    if Self.isComponentValuePredicate(predicate) {
                        Image(systemName: "skew").font(.headline).foregroundColor(.accentColor)
                    } else {
                        Image(systemName: "questionmark").font(.headline)
                    }
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
                if p.subpredicates[1] is NSComparisonPredicate {
                    let lhs = p.subpredicates[0] as! NSComparisonPredicate
                    let rhs = p.subpredicates[1] as! NSComparisonPredicate
                    let characteristic = lhs.rightExpression.constantValue as! HMCharacteristic
                    return predicateDescription(NSComparisonPredicate(leftExpression: lhs.rightExpression, rightExpression: rhs.rightExpression, modifier: rhs.comparisonPredicateModifier, type: rhs.predicateOperatorType, options: rhs.options)) + CurrentPower.unit(characteristic)
                } else {
                    let lhs = p.subpredicates[0] as! NSComparisonPredicate
                    let rhss = (p.subpredicates[1] as! NSCompoundPredicate).subpredicates.map({s in (s as! NSComparisonPredicate)})
                    return expressionDescription(lhs.rightExpression) + " \(modifierDescription(.direct)) " + rhss.map({p in operatorDescription(p.predicateOperatorType) + " " + expressionDescription(p.rightExpression)}).joined(separator: " \(compoundTypeDescription(.and)) ")
                }
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
    
    static func isComponentValuePredicate(_ predicate: NSPredicate) -> Bool {
        if let p = predicate as? NSCompoundPredicate {
            if p.subpredicates.count == 2 && p.compoundPredicateType == .and && p.subpredicates[0] is NSComparisonPredicate &&  p.subpredicates[1] is NSComparisonPredicate {
                let lhs = p.subpredicates[0] as! NSComparisonPredicate
                let rhs = p.subpredicates[1] as! NSComparisonPredicate
                if lhs.comparisonPredicateModifier == .direct && lhs.predicateOperatorType == .equalTo && lhs.leftExpression.expressionType == .keyPath && lhs.leftExpression.keyPath == "characteristic" {
                    if rhs.leftExpression.expressionType == .keyPath && rhs.leftExpression.keyPath == "characteristicValue" {
                        return true
                    }
                }
            } else if p.subpredicates.count == 2 && p.compoundPredicateType == .and && p.subpredicates[0] is NSComparisonPredicate &&  p.subpredicates[1] is NSCompoundPredicate {
                let lhs = p.subpredicates[0] as! NSComparisonPredicate
                let rhs = p.subpredicates[1] as! NSCompoundPredicate
                if lhs.comparisonPredicateModifier == .direct && lhs.predicateOperatorType == .equalTo && lhs.leftExpression.expressionType == .keyPath && lhs.leftExpression.keyPath == "characteristic" && rhs.compoundPredicateType == .and {
                    for sp in rhs.subpredicates {
                        if let s = sp as? NSComparisonPredicate {
                            if s.leftExpression.expressionType != .keyPath || s.leftExpression.keyPath != "characteristicValue" {
                                return false
                            }
                        } else {
                            return false
                        }
                    }
                    return true
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
                return String(format: "%02d:%02d", v.hour, v.minute)
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


// MARK: NewPredicateView
struct NewPredicateView: View {
    
    enum CharacteristicPredicateType: String {
        case equality = "is equal to"
        case lessOrEqual = "is less than or equal to"
        case greaterOrEqual = "is greater than or equal to"
        case between = "is between"
        
        static func all() -> [CharacteristicPredicateType] {
            return [.equality, .lessOrEqual, .greaterOrEqual, .between]
        }
    }
    
    @EnvironmentObject var home: Home
    
    @ObservedObject var trigger: Trigger<HMEventTrigger>
    
    let done: (_: NSPredicate?) -> ()
    
    private var validConfiguration: Bool {
        get {
            if self.characteristic == nil {
                return false
            }
            switch self.type {
            case .equality:
                if let c = CurrentPower.isContinuous(self.characteristic!) {
                    if c {
                        return CurrentPower.isValid(self.firstBoundary, for: self.characteristic!)
                    } else {
                        return CurrentPower.isValid(self.selection, for: self.characteristic!)
                    }
                } else {
                    return false
                }
            case .lessOrEqual, .greaterOrEqual:
                return CurrentPower.isValid(self.firstBoundary, for: self.characteristic!)
            case .between:
                return CurrentPower.isValid(self.firstBoundary, for: self.characteristic!) && CurrentPower.isValid(self.secondBoundary, for: self.characteristic!) && Float(self.firstBoundary)! <= Float(self.secondBoundary)!
            }
        }
    }
    
    @State private var characteristic: HMCharacteristic? = nil
    
    @State private var type: CharacteristicPredicateType = .equality
    
    @State private var selection: NSNumber = 0
    
    @State private var firstBoundary: String = ""
    
    @State private var secondBoundary: String = ""
    
    
    @ViewBuilder
    var body: some View {
        NavigationView {
            VStack {
                WrapperView(edges: .top) {
                    if self.characteristic == nil {
                        NavigationLink(destination: RoomPickerView(characteristic: self.$characteristic).environmentObject(self.home), label: {
                            HStack {
                                Image(systemName: "skew").font(Font.system(.title)).foregroundColor(.accentColor)
                                Text("Select a characteristic")
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.secondary).font(Font.system(.footnote))
                            }
                        })
                    } else {
                        HStack {
                            Image(systemName: "skew").font(Font.system(.title)).foregroundColor(.accentColor)
                            Text(CurrentPower.description(self.characteristic!))
                            Spacer()
                            Button(action: {
                                self.characteristic = nil
                                self.type = .equality
                            }, label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.accentColor)
                            })
                        }
                    }
                    
                }

                if self.characteristic != nil {
                    
                    if CurrentPower.isContinuous(self.characteristic!) == nil {
                        Text("Cannot interprete this characteristic. Please select a different characteristic or use a different app to create this trigger.").multilineTextAlignment(.center).lineLimit(nil).fixedSize(horizontal: false, vertical: true).foregroundColor(.secondary).padding(.vertical)
                    } else if CurrentPower.isContinuous(self.characteristic!)! {
                        Picker(selection: self.$type, label: EmptyView()) {
                            ForEach(CharacteristicPredicateType.all(), id: \.rawValue) { t in
                                Text(t.rawValue).tag(t)
                            }
                        }
                        
                        WrapperView(edges: .bottom) {
                            HStack {
                                TextField(self.type == .equality ? "value" : self.type == .lessOrEqual ? "upper bound" : "lower bound", text: self.$firstBoundary) {
                                    UIApplication.shared.endEditing()
                                }
                                .keyboardType(.numbersAndPunctuation)
                                Text(CurrentPower.unit(self.characteristic!))
                            }
                        }
                        
                        if self.type == .between {
                            Text("and").padding(.bottom)
                            
                            WrapperView(edges: .bottom) {
                                HStack {
                                    TextField("upper bound", text: self.$secondBoundary) {
                                        UIApplication.shared.endEditing()
                                    }
                                    .keyboardType(.numbersAndPunctuation)
                                    Text(CurrentPower.unit(self.characteristic!))
                                }
                            }
                        }
                        
                    } else {
                        Text(CharacteristicPredicateType.equality.rawValue).padding(.top)
                        
                        Picker(selection: self.$selection, label: EmptyView()) {
                            ForEach(self.characteristic!.metadata!.validValues!, id: \.description) { v in
                                Text(CurrentPower.format(v, as: self.characteristic!)).tag(v)
                            }
                        }
                    }
                }
                
                Spacer().layoutPriority(4)
            }.padding()
            .navigationBarTitle("Add a condition", displayMode: .inline)
            .navigationBarItems(leading: Button(action: { self.done(nil) }, label: {
                Text("Cancel").foregroundColor(.red)
            }), trailing: Button(action: {
                var predicate: NSPredicate
                let lhs = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "characteristic"), rightExpression: NSExpression(forConstantValue: self.characteristic!), modifier: .direct, type: .equalTo)
                switch self.type {
                case .equality:
                    if CurrentPower.isContinuous(self.characteristic!)! {
                        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [lhs,
                            NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "characteristicValue"), rightExpression: NSExpression(forConstantValue: Float(self.firstBoundary)!), modifier: .direct, type: .equalTo)
                        ])
                    } else {
                        predicate =  NSCompoundPredicate(andPredicateWithSubpredicates: [lhs,
                            NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "characteristicValue"), rightExpression: NSExpression(forConstantValue: self.selection), modifier: .direct, type: .equalTo)
                        ])
                    }
                default:
                    switch self.type {
                    case .lessOrEqual:
                        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [lhs,
                            NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "characteristicValue"), rightExpression: NSExpression(forConstantValue: Float(self.firstBoundary)!), modifier: .direct, type: .lessThanOrEqualTo)
                        ])
                    case .greaterOrEqual:
                        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [lhs,
                            NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "characteristicValue"), rightExpression: NSExpression(forConstantValue: Float(self.firstBoundary)!), modifier: .direct, type: .greaterThanOrEqualTo)
                        ])
                    default:
                        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [lhs,
                            NSCompoundPredicate(andPredicateWithSubpredicates: [
                                NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "characteristicValue"), rightExpression: NSExpression(forConstantValue: Float(self.firstBoundary)!), modifier: .direct, type: .greaterThanOrEqualTo),
                                NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "characteristicValue"), rightExpression: NSExpression(forConstantValue: Float(self.secondBoundary)!), modifier: .direct, type: .lessThanOrEqualTo)
                            ])
                        ])
                    }
                }
                self.done(predicate)
            }, label: {
                Text("Done").foregroundColor(.accentColor)
            })
            .disabled(!self.validConfiguration))
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}
