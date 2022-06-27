//
//  GridListView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI

struct ColorGrid: Identifiable, Codable {
    var name: String
    var id: String
    var grid: [[Color]]
    var sentAt: Date = Date()
    
    func toHex() -> [String] {
        return grid.flatMap { $0 }.map { $0.hex }
    }
    
    mutating func updateDate() {
        sentAt = Date()
    }
    
    static func example(color: Color) -> ColorGrid {
        return ColorGrid(
            name: "Example",
            id: UUID().uuidString,
            grid: Array(repeating: Array(repeating: color, count: 8), count: 8),
            sentAt: Date()
        )
    }
}

class GridListViewModel: ObservableObject {
    @Published var grids: [ColorGrid]
    
    var onSave: ([ColorGrid]) -> Void
    
    init(grids: [ColorGrid], onSave: @escaping ([ColorGrid]) -> Void) {
        self.grids = grids
        self.onSave = onSave
    }
    
    func removeGrid(_ item: ColorGrid) {
        grids.removeAll(where: { $0.id == item.id } )
        save()
    }
    
    func save() {
        onSave(grids)
    }
    
    func setGrids(_ grids: [ColorGrid]) {
        self.grids = grids
    }
}

struct GridListView: View {
    @ObservedObject var viewModel: GridListViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    func gridButton(item: ColorGrid) -> some View {
        Button {
            PeripheralManager.shared.sendToDevice(colors: item.toHex())
        } label: {
            VStack {
                MiniGridView(grid: item.grid)
                    .drawingGroup()
            }.padding(15)
        }.buttonStyle(.plain)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(15)
            .padding(.leading, 5)
            .contextMenu {
                Button {
                    PeripheralManager.shared.sendToDevice(colors: item.toHex())
                } label: {
                    Label("Send to Device", systemImage: "globe")
                }
                
                Button(role: .destructive) {
                    viewModel.removeGrid(item)
                } label: {
                    Label("Delete", systemImage: "xmark").tint(.red)
                }
            }
    }
    
    var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(viewModel.grids) { item in
                        gridButton(item: item)
                    }
                }
                .padding(.horizontal)
        }
    }
}

//struct GridListView_Previews: PreviewProvider {
//    static var previews: some View {
//        GridListView(grids: [
//            ColorGrid.example(color: .blue),
//            ColorGrid.example(color: .pink),
//            ColorGrid.example(color: .red),
//            ColorGrid.example(color: .yellow),
//        ])
//    }
//}
