//
//  DrawingList.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/02/2024.
//

import SwiftUI

struct DrawingList<Content: View>: View {
    let columns = [
        GridItem(.flexible(minimum: 80)),
        GridItem(.flexible(minimum: 80)),
    ]

    var drawings: [any Drawing]

    @ViewBuilder var content: (any Drawing, Int) -> Content

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(Array(drawings.enumerated()), id: \.element.id) { index, drawing in
                    content(drawing, index)
                }
            }
        }
    }
}

#Preview {
    DrawingList(drawings: [], content: { _, _ in EmptyView() })
}
