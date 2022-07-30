//
//  ReceivedView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI

struct ReceivedView: View {
    @ObservedObject var manager = GridManager.shared
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        NavigationView {
            RefreshableScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(manager.receivedGrids) { item in
                        MiniGridView(grid: item.grid)
                            .drawingGroup()
                    }
                }
                .padding(.horizontal)
            } onRefresh: {
                Task {
                    await GridManager.shared.refreshReceivedGrids()
                }
            }.navigationTitle("Received Grids")
        }
    }
}

struct ReceivedView_Previews: PreviewProvider {
    static var previews: some View {
        ReceivedView()
    }
}

struct RefreshableScrollView<Content: View>: View {
    var content: Content
    var onRefresh: () -> Void

    public init(content: @escaping () -> Content, onRefresh: @escaping () -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
    }

    public var body: some View {
        List {
            content
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .refreshable {
            onRefresh()
        }
    }
}
