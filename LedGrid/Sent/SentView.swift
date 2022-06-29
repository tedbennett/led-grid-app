//
//  SentView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI

struct SentView: View {
    @StateObject var viewModel = GridListViewModel(grids: Utility.sentGrids.sorted(by: {$0.sentAt > $1.sentAt})) {
        Utility.sentGrids = $0
    }
    
    var body: some View {
        NavigationView {
            GridListView(viewModel: viewModel) {
                viewModel.setGrids(Utility.sentGrids)
            }.navigationTitle("Sent Grids")
        }.onAppear {
            viewModel.setGrids(Utility.sentGrids)
        }
    }
}

struct SentView_Previews: PreviewProvider {
    static var previews: some View {
        SentView()
    }
}
