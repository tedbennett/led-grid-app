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
    @State private var selectedDraftId: String?

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        DrawView(selectedDraftId: $selectedDraftId) {
                            scrollProxy.scrollTo(Tab.art)
                        }.safeAreaPadding().frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        ).id(Tab.draw)
                        DrawingsView(selectedDraftId: $selectedDraftId) {
                            scrollProxy.scrollTo(Tab.draw)
                        }.safeAreaPadding().frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        ).id(Tab.art)
                    }.scrollIndicators(.never)
                        .scrollTargetBehavior(.paging).toolbar(.hidden)
                        .scrollBounceBehavior(.basedOnSize)
                        .frame(maxHeight: .infinity)
                }
            }.ignoresSafeArea()
        }.background(Color(uiColor: .secondarySystemBackground))
    }
}

#Preview {
    Home()
}
