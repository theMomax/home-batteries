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

struct WrapperView<Content> : View where Content : View {
    
    private let context: () -> Content
    private let alignment: Alignment
    private let boxed: Bool
    private let edges: Edge.Set
    private let padding: CGFloat?
    
    @Environment(\.colorScheme) var colorScheme
    
    @inlinable init(edges: Edge.Set = .all, padding: CGFloat? = nil, alignment: Alignment = .center, boxed: Bool = true, @ViewBuilder _ content: @escaping () -> Content) {
        self.context = content
        self.alignment = alignment
        self.boxed = boxed
        self.padding = padding
        self.edges = edges
    }

    @ViewBuilder
    var body: some View {
        ZStack(alignment: alignment) {
            if self.boxed {
                if colorScheme != .dark {
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
                
            context().padding()
        }
        .padding(self.edges, self.padding)
    }
}


struct AccessoryWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                
                
                ScrollView {
                    VStack {
                        WrapperView() {
                            Text("1")
                        }
                        WrapperView(alignment: .topLeading) {
                            Text("2")
                        }
                        WrapperView() {
                            Image(systemName: "pencil.slash").font(Font.system(.largeTitle))
                        }
                    }
                }
            }
                
                
            .previewDisplayName("\(colorScheme)")
            .environment(\.colorScheme, colorScheme)
        }
    }
}
