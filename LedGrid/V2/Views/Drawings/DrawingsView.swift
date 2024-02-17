//
//  DrawingsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/06/2023.
//

import SwiftData
import SwiftUI

enum DrawingsTab: String {
    case sent
    case received
    case drafts
}

struct DrawingsView: View {
    @State private var tab = DrawingsTab.drafts

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \DraftDrawing.updatedAt, order: .reverse, animation: .bouncy) var drafts: [DraftDrawing] = []
    @Query(sort: \ReceivedDrawing.createdAt, order: .reverse, animation: .bouncy) var received: [ReceivedDrawing] = []
    @Query(sort: \SentDrawing.createdAt, order: .reverse, animation: .bouncy) var sent: [SentDrawing] = []

    @State private var feedback = false

    let scrollToDrawView: () -> Void

    func selectDraft(at index: Int) {
        do {
            feedback.toggle()
            let draft = drafts[index]
            draft.updatedAt = .now
            try modelContext.save()
            withAnimation {
                scrollToDrawView()
            }
        } catch {
            print(error)
        }
    }

    var body: some View {
        VStack {
            let drawings: [any Drawing] = {
                switch tab {
                case .sent: return sent
                case .received: return received
                case .drafts: return drafts
                }
            }()
            DrawingsHeader(tab: $tab)
            DrawingList(drawings: drawings) { index in
                guard tab != .drafts else {
                    return
                }
                selectDraft(at: index)
            }
        }
    }
}

struct ArtViewPreview: PreviewProvider {
    static var previews: some View {
        DrawingsView {}
            .modelContainer(PreviewStore.container)
    }
}
