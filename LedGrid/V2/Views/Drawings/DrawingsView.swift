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
    @Binding var selectedDraftId: String?

    @Query(sort: \DraftDrawing.updatedAt, order: .reverse, animation: .bouncy) var drafts: [DraftDrawing] = []
    @Query(sort: \ReceivedDrawing.createdAt, order: .reverse, animation: .bouncy) var received: [ReceivedDrawing] = []
    @Query(sort: \SentDrawing.createdAt, order: .reverse, animation: .bouncy) var sent: [SentDrawing] = []

    @State private var feedback = false

    let scrollToDrawView: () -> Void
    
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
            DrawingList(drawings: drawings) { id in
                selectedDraftId = id
                feedback.toggle()
                withAnimation {
                    scrollToDrawView()
                }
            }
        }
    }
}

struct ArtViewPreview: PreviewProvider {
    static var selectedUUID = UUID().uuidString
    static var container = {
        let container = try! ModelContainer(for: DraftDrawing.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let selected = DraftDrawing()
        selected.id = selectedUUID
        container.mainContext.insert(selected)
        container.mainContext.insert(DraftDrawing())
        container.mainContext.insert(DraftDrawing())
        return container
    }()

    static var previews: some View {
        DrawingsView(selectedDraftId: .constant(selectedUUID)) {}
            .modelContainer(container)
    }
}
