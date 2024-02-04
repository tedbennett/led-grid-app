//
//  PageView.swift
//  LedGrid
//
//  Created by Ted Bennett on 03/02/2024.
//

import SwiftUI

struct PageView: View {
    @State private var selectedDraftId: UUID?
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
                        ArtView(selectedDraftId: $selectedDraftId) {
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
