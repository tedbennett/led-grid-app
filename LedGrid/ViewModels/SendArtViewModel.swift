//
//  SendArtViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/10/2022.
//

import Foundation

class SendArtViewModel: ObservableObject {
    
    @Published var selectedUsers: [String] = Utility.lastSelectedFriends
    @Published var sendingArt = false
    
    var grids: [Grid]
    
    init(grids: [Grid]) {
        self.grids = grids
    }
    
    func sendArt() async -> Bool {
        await MainActor.run {
            sendingArt = true
        }
        Utility.lastSelectedFriends = selectedUsers
        let success = await PixeeProvider.sendArt(to: selectedUsers, grids: grids)
        await MainActor.run {
            sendingArt = false
        }
        return success
    }
}
