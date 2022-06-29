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
    
    var body: some View {
        NavigationView {
            GridListView(viewModel: viewModel) {
                viewModel.setGrids(Utility.receivedGrids)
            }
            .navigationTitle("Received Grids")
        }.onAppear {
            viewModel.setGrids(Utility.receivedGrids)
        }
    }
}

struct ReceivedView_Previews: PreviewProvider {
    static var previews: some View {
        ReceivedView()
    }
}
