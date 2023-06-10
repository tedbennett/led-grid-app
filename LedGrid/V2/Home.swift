//
//  Home.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/06/2023.
//

import OSLog
import SwiftUI
import SwiftData
let logger = Logger(subsystem: "Pixee", category: "Canvas")

enum Tab: Hashable {
    case draw
    case art
}


struct Home: View {
    @State private var tab: Tab = .draw
    @State private var currentDraft: DraftArt?
    
    var body: some View {
        ZStack {
            TabView(selection: $tab) {
                DrawView() {
                    tab = $0
                }
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
