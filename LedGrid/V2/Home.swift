//
//  Home.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/06/2023.
//

import OSLog
import SwiftUI

let logger = Logger(subsystem: "Pixee", category: "Canvas")

struct Home: View {
    @State private var tab = 0
    let model = GridModel()
    @State private var color = Color.green

    var body: some View {
        ZStack {
            TabView(selection: $tab) {
                ZStack {
                    VStack {
                        Spacer()
                        CanvasView(model: model, color: color)
                        Spacer()
                    }
                    VStack {
                        Spacer().allowsHitTesting(false)
                        BottomBarView(model: model, color: $color)
                    }
                }.tag(0)
                VStack {
                    Text("First")
                }.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeOut(duration: 0.2), value: tab)
            VStack {
                HeaderBarView(tab: $tab)
                Spacer().allowsHitTesting(false)
            }
        }.background(Color(uiColor: .secondarySystemBackground))
    }
}

#Preview {
    Home()
}
