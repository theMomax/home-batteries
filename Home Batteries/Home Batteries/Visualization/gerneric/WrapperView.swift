//
//  AccessoryWrapperView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 01.05.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI
import HomeKit
import SwiftUICharts

struct WrapperView<Content> : View where Content : View {
    
    private let context: () -> Content
    private let alignment: Alignment
    private let boxed: Bool
    private let edges: Edge.Set
    private let padding: CGFloat?
    private let innerPadding: CGFloat?
    
    @Environment(\.colorScheme) var colorScheme
    
    @inlinable init(edges: Edge.Set = .all, padding: CGFloat? = nil, innerPadding: CGFloat? = nil, alignment: Alignment = .center, boxed: Bool = true, @ViewBuilder _ content: @escaping () -> Content) {
        self.context = content
        self.alignment = alignment
        self.boxed = boxed
        self.padding = padding
        self.edges = edges
        self.innerPadding = innerPadding
    }

    @ViewBuilder
    var body: some View {
            ZStack(alignment: self.alignment) {
                if self.boxed {
                    if self.colorScheme != .dark {
                        RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color(.systemBackground))
                        .shadow(color: Color.gray.opacity(0.3), radius: 10)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.init(white: 0.1))
                    }
                } else {
                    RoundedRectangle(cornerRadius: 15)
                    .opacity(0)
                }
                    
                if self.innerPadding == nil {
                    self.context().padding()
                } else {
                    self.context().padding(self.innerPadding!)
                }
            }
            .padding(self.edges, self.padding)
    }
}


struct AccessoryWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                
                
                VStack {
                    WrapperView {
                        LineChartView(data: [8,23,54,32,12,37,7,23,43], title: "Title", legend: "Legendary", dropShadow: false)
                    }
                    WrapperView(alignment: .topLeading) {
                        Text("2")
                    }
                    WrapperView() {
                        Image(systemName: "pencil.slash").font(Font.system(.largeTitle))
                    }
                }
            }
                
                
            .previewDisplayName("\(colorScheme)")
            .environment(\.colorScheme, colorScheme)
        }
    }
}
