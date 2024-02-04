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

    var onSelect: (String) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(drawings, id: \.id) { drawing in
                    GridView(grid: drawing.grid).aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture {
                            onSelect(drawing.id)
                        }
                }
            }
        }
    }
}

#Preview {
    DrawingList(drawings: [], onSelect: { _ in })
}
