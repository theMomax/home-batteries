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
    
    @inlinable init(alignment: Alignment = .center, @ViewBuilder _ content: @escaping () -> Content) {
        self.context = content
        self.alignment = alignment
    }

    var body: some View {
        ZStack(alignment: alignment) {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color(.systemBackground))
                .shadow(color: .gray, radius: 5)
                
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
