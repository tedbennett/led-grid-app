//
//  SentView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI

struct SentView: View {
    @ObservedObject var manager = GridManager.shared
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(manager.sentGrids) { item in
                        MiniGridView(grid: item.grid)
                            .drawingGroup()
                    }
                }
                .padding(.horizontal)
                
            }.navigationTitle("Sent Grids")
        }
    }
}

struct SentView_Previews: PreviewProvider {
    static var previews: some View {
        SentView()
    }
}

