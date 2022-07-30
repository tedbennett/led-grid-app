//
//  GridListView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI

class GridListViewModel: ObservableObject {
    @Published var grids: [ColorGrid]
    
    var onSave: ([ColorGrid]) -> Void
    
    init(grids: [ColorGrid], onSave: @escaping ([ColorGrid]) -> Void) {
        self.grids = grids
        self.onSave = onSave
    }
    
    func onSelectGrid(_ item: ColorGrid) {
        
    }
    
    func removeGrid(_ item: ColorGrid) {
        grids.removeAll(where: { $0.id == item.id } )
        save()
    }
    
    func save() {
        onSave(grids)
    }
    
    func setGrids(_ grids: [ColorGrid]) {
        self.grids = grids.sorted(by: { $0.sentAt > $1.sentAt })
    }
}

struct GridListView: View {
    @ObservedObject var viewModel: GridListViewModel
    
    var onRefresh: () -> Void
    var onSelectGrid: () -> Void
    
    init(viewModel: GridListViewModel, onRefresh: @escaping () -> Void, onSelectGrid: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.onRefresh = onRefresh
        self.onSelectGrid = onSelectGrid
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
//    func gridButton(item: ColorGrid) -> some View {
//        Button {
//
//        } label: {
//            VStack {
//                    MiniGridView(grid: item.grid)
//                        .drawingGroup()
//            }.padding(15)
//        }.buttonStyle(.plain)
//            .background(Color(uiColor: .systemGray6))
//            .cornerRadius(15)
//            .padding(.leading, 5)
//            .contextMenu {
//                Button {
//
//                } label: {
//                    Label("Send to Device", systemImage: "globe")
//                }
//
//                Button(role: .destructive) {
//                    viewModel.removeGrid(item)
//                } label: {
//                    Label("Delete", systemImage: "xmark").tint(.red)
//                }
//            }
//    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 30) {
                ForEach(viewModel.grids) { item in
                    MiniGridView(grid: item.grid)
                        .drawingGroup()
                }
            }
            .padding(.horizontal)
            .refreshable {
                onRefresh()
            }
        }
    }
}

struct GridListView_Previews: PreviewProvider {
    static var previews: some View {
        GridListView(viewModel: GridListViewModel(grids: [
            ColorGrid.example(color: .blue),
            ColorGrid.example(color: .pink),
            ColorGrid.example(color: .red),
            ColorGrid.example(color: .yellow),
        ], onSave: { _ in }), onRefresh: {})
    }
}
