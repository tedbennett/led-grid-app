//
//  Home.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/06/2023.
//

import OSLog
import SwiftData
import SwiftUI
let logger = Logger(subsystem: "Pixee", category: "Canvas")

enum Tab: Hashable {
    case drafts
    case draw
    case art
}

struct Home: View {
    @State private var tab: Tab = .draw
    @State private var currentDraft: DraftArt?
    @State private var selectedDraftId: UUID?

    var body: some View {
            DrawView {
                tab = $0
            }

//                VStack {
//                    HeaderBarView(tab: $tab)
//                    Spacer().allowsHitTesting(false)
//                }
    }
}

#Preview {
    Home()
}
