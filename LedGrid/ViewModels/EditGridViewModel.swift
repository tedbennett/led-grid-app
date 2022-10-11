//
//  EditGridViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/10/2022.
//

import Foundation

class EditGridViewModel: ObservableObject {
    
    @Published var undoStates: [Grid] = []
    @Published var redoStates: [Grid] = []
    
    private var currentState: Grid = {
        let grids = Utility.currentGrids
        return Utility.currentGridIndex < grids.count ? grids[Utility.currentGridIndex] : grids[0]
    }()
}
