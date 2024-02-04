//
//  DrawView.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/06/2023.
//

import SwiftData
import SwiftUI

struct DrawView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DraftArt.lastUpdated, order: .reverse)
    var drafts: [DraftArt] = []
    @State private var color = Color.green

    @State private var undoStack: [Grid] = []
    @State private var redoStack: [Grid] = []

    @Binding var selectedDraftId: UUID?

    let changeTab: () -> Void
    func pushUndo(_ newGrid: Grid) {
        undoStack.append(newGrid)
        redoStack = []
    }

    func undo() {
        guard let newGrid = undoStack.popLast() else { return }
        guard let grid = drafts.first?.grid else { return }
        redoStack.append(grid)
        drafts.first?.grid = newGrid
        try? modelContext.save()
    }

    func redo() {
        guard let newGrid = redoStack.popLast() else { return }
        guard let grid = drafts.first?.grid else { return }
        undoStack.append(grid)
        drafts.first?.grid = newGrid
        try? modelContext.save()
    }

    func send() {
        modelContext.insert(DraftArt())
        try! modelContext.save()
    }

    var body: some View {
        VStack {
            HeaderView().padding(.top, 50).padding(.leading, 20)
            Spacer()

            let selectedDraft = if let selectedDraftId {
                drafts.first(where: { $0.id == selectedDraftId })
            } else {
                drafts.first
            }

            if let art = selectedDraft {
                CanvasView(art: art, color: color) { pushUndo($0) }

            } else {
                ProgressView()
                    .onAppear {
                        modelContext.insert(DraftArt())
                    }
            }
            Spacer()
            BottomBarView(color: $color, canUndo: !undoStack.isEmpty, canRedo: !redoStack.isEmpty) {
                undo()
            } redo: {
                redo()
            } send: {
                send()
            }
            Button {
                withAnimation {
                    changeTab()
                }
            } label: {
                HStack {
                    Text("View Drawings")
                    Image(systemName: "chevron.down")
                }
            }
        }
    }
}

#Preview {
    DrawView(selectedDraftId: .constant(UUID())) {}
}
