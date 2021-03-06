//
//  OutletServiceView.swift
//  Home Batteries
//
//  Created by Max Obermeier on 28.06.20.
//  Copyright © 2020 Max Obermeier. All rights reserved.
//

import SwiftUI
import HomeKit

struct OutletServiceView: View {
    
    let service: OutletService
    
    @ObservedObject var on: Characteristic<Bool>
    @ObservedObject var outletInUse: Characteristic<Bool>
    
    @Binding var processing: Bool
       
    init(_ service: OutletService, processing: Binding<Bool> = .constant(false)) {
        self.service = service
        self.on = service.on.observable()
        self.outletInUse = service.outletInUse.observable()
        self._processing = processing
    }
    
    @ViewBuilder
    var body: some View {
        OutletView(on: self.$on.value, outletInUse: self.$outletInUse.value, processing: self.$processing)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.on.reload()
            self.outletInUse.reload()
        }
    }
    
}

struct OutletView: View {
    
    @Binding var on: Bool?
    
    @Binding var outletInUse: Bool?
    
    @Binding var processing: Bool
    
    init(on: Binding<Bool?>, outletInUse: Binding<Bool?>, processing: Binding<Bool> = .constant(false)) {
        self._on = on.animation()
        self._outletInUse = outletInUse
        self._processing = processing
    }
    
    var body: some View {
        HStack(alignment: .top) {
            ZStack {
                ProgressView().opacity(self.processing ? 1 : 0)
                Image(systemName: "power")
                    .font(.title)
                    .foregroundColor(self.on != nil && self.on! ? .blue : .secondary)
                    .opacity(self.processing ? 0 : 1)
            }
            
            Spacer()
            Text(OutletInUse.format(outletInUse)).lineLimit(1).font(.footnote).foregroundColor(.secondary)
        }
    }
}


struct OutletServiceView_Previews: PreviewProvider {
        
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach([true, false], id: \.self) { on in
                ZStack {
                    Color(.systemBackground).edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        HStack {
                            WrapperView {
                                OutletView(on: .constant(on), outletInUse: .constant(true))
                            }
                            WrapperView {
                                OutletView(on: .constant(on), outletInUse: .constant(false))
                            }
                        }
                    }
                }
                
                
                .previewDisplayName("\(colorScheme) -> \(on)")
            }
            .environment(\.colorScheme, colorScheme)
        }
    }
}
