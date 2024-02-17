//
//  DrawingList.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/02/2024.
//

import SwiftUI

protocol Drawing: Identifiable {
    var id: String { get set }
    var grid: Grid { get set }
}

struct DrawingList: View {
    let columns = [
        GridItem(.flexible(minimum: 80)),
        GridItem(.flexible(minimum: 80)),
    ]

    var drawings: [any Drawing]

    var onSelectAtIndex: (Int) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(Array(drawings.enumerated()), id: \.element.id) { index, drawing in
                    GridView(grid: drawing.grid).aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture {
                            onSelectAtIndex(index)
                        }
                }
            }
        }
    }
}

#Preview {
    DrawingList(drawings: [], onSelectAtIndex: { _ in })
}
