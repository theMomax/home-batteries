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

enum Style {
    case elevated, inset, outset, invisible
}

struct WrapperView<Content> : View where Content : View {
    
    private let content: () -> Content
    private let alignment: Alignment
    private let style: Style
    private let edges: Edge.Set
    private let padding: CGFloat?
    private let innerPadding: CGFloat?
    private let innerEdges: Edge.Set
    
    @Environment(\.colorScheme) var colorScheme
    
    @inlinable init(edges: Edge.Set = .all, padding: CGFloat? = nil, innerEdges: Edge.Set = .all, innerPadding: CGFloat? = nil, alignment: Alignment = .center, style: Style = .elevated, @ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
        self.alignment = alignment
        self.style = style
        self.padding = padding
        self.edges = edges
        self.innerPadding = innerPadding
        self.innerEdges = innerEdges
    }

    @ViewBuilder
    var body: some View {
            ZStack(alignment: self.alignment) {
                if self.style == Style.elevated {
                    if self.colorScheme != .dark {
                        RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color(.systemBackground))
                        .shadow(color: Color.gray.opacity(0.3), radius: 10)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color(.secondarySystemBackground))
                    }
                } else if self.style == Style.invisible {
                    RoundedRectangle(cornerRadius: 15)
                    .opacity(0)
                } else {
                    RoundedRectangle(cornerRadius: 15).foregroundColor(self.style == .outset ? Color.outsetBackground : Color.tintedBackground)
                }
                    
                if self.innerPadding == nil {
                    self.content().padding(self.innerEdges)
                } else {
                    self.content().padding(self.innerEdges, self.innerPadding!)
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
