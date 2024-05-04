//
//  DrawingList.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/02/2024.
//

import SwiftUI


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
                    VStack(alignment: .center) {
                        GridView(grid: drawing.grid)
                            .aspectRatio(contentMode: .fit)
                            .blur(radius: drawing.opened ? 0 : 20)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color.gray.opacity(0.2), lineWidth: 1
                                    )
                            )
                            .overlay(
                                Image(systemName: "eye")
                                    .foregroundStyle(.gray)
                                    .opacity(drawing.opened ? 0 : 1))
                            .font(.title)
                            .padding(1)
                            .onTapGesture {
                                onSelectAtIndex(index)
                            }
                        if let friend = drawing.sender {
                            Text("From \(friend.name ?? friend.username)").foregroundStyle(.secondary).italic().font(.caption)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DrawingList(drawings: [], onSelectAtIndex: { _ in })
}
