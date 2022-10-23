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
    @Published var emojiPickerOpen = false
    @Published var didSendGrid: Bool = false
    @Published var failedToSendGrid: Bool = false
    
    var userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func sendReaction(_ reaction: String, for art: PixelArt) {
        if !emojis.contains(reaction) {
            emojis = [reaction] + Array(emojis.prefix(emojis.count - 1))
            Utility.lastReactions = emojis
        }
        Task {
            let success = await PixeeProvider.sendReaction(for: art, reaction: reaction)
            await MainActor.run {
                if success {
                    didSendGrid = true
                } else {
                    failedToSendGrid = true
                }
            }
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
