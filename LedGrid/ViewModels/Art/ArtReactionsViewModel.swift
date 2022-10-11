//
//  ArtReactionsViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/10/2022.
//

import SwiftUI

class ArtReactionsViewModel: ObservableObject {
    @Published var emojis: [String] = Utility.lastReactions
    
    /// Art card id with opened reactions
    @Published var openedReactionsId: String?
    
    func sendReaction(_ reaction: String) {
        if !emojis.contains(reaction) {
            emojis = [reaction] + Array(emojis.prefix(emojis.count - 1))
            Utility.lastReactions = emojis
        }
        
        // Send reaction
        closeReactions()
    }
    
    func openReactions(for id: String) {
        withAnimation {
            openedReactionsId = id
        }
    }
    
    func closeReactions() {
        withAnimation {
            openedReactionsId = nil
        }
    }
}
