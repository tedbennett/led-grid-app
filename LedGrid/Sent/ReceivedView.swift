//
//  ReceivedView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI

struct ReceivedView: View {
    @StateObject var viewModel = GridListViewModel(grids: Utility.receivedGrids.sorted(by: {$0.sentAt > $1.sentAt})) {
        Utility.receivedGrids = $0
    }
    
    @Binding var unopenedGrids: Int
    
    var body: some View {
        NavigationView {
            GridListView(viewModel: viewModel) {
                viewModel.setGrids(Utility.receivedGrids)
            } onSelectGrid: {
                unopenedGrids = Utility.receivedGrids.reduce(0, { a, b in !b.opened ? a + 1 : a })
            }
            .navigationTitle("Received Grids")
        }.onAppear {
            viewModel.setGrids(Utility.receivedGrids)
        }
    }
}

struct ReceivedView_Previews: PreviewProvider {
    static var previews: some View {
        ReceivedView(unopenedGrids: .constant(0))
    }
}
