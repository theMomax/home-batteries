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

struct AccessoryWrapperView<Content> : View where Content : View {
    
    private let context: () -> Content
    private let alignment: Alignment
    private let dropShadow: Bool
    
    @inlinable init(alignment: Alignment = .center, dropShadow: Bool = true, @ViewBuilder _ content: @escaping () -> Content) {
        self.context = content
        self.alignment = alignment
        self.dropShadow = dropShadow
    }

    @ViewBuilder
    var body: some View {
        ZStack(alignment: alignment) {
            if self.dropShadow {
                RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color(.systemBackground))
                .shadow(color: .gray, radius: 5)
            } else {
                RoundedRectangle(cornerRadius: 20)
                .opacity(0)
            }
                
            context().padding()
        }
        .padding(.init(arrayLiteral: .horizontal, .bottom))
    }
}


struct AccessoryWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                
                
                ScrollView {
                    VStack {
                        AccessoryWrapperView() {
                            Text("1")
                        }
                        AccessoryWrapperView(alignment: .topLeading) {
                            Text("2")
                        }
                        AccessoryWrapperView() {
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
