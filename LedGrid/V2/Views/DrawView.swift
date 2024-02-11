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
    @Query(sort: \DraftDrawing.updatedAt, order: .reverse) var drafts: [DraftDrawing] = []
    @Query var friends: [Friend] = []
    @State private var color = Color.green

    @State private var undoStack: [Grid] = []
    @State private var redoStack: [Grid] = []

    @Binding var selectedDraftId: String?

    let scrollToArtView: () -> Void

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

    func send(grid: Grid) {
        Task.detached {
            do {
                let container = Container()
                let now = Date.now
                let friends = friends.map(\.id)
                try await API.sendDrawing(grid, to: friends)
                let drawings = try await API.getSentDrawings(since: now)
                try await container.insertSentDrawings(drawings)
                let id = try await container.createDraft()
                await MainActor.run {
                    selectedDraftId = id
                }
            } catch {
                logger.error("\(error.localizedDescription)")
            }
        }
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
                        modelContext.insert(DraftDrawing())
                    }
            }
            Spacer()
            BottomBarView(color: $color, canUndo: !undoStack.isEmpty, canRedo: !redoStack.isEmpty) {
                undo()
            } redo: {
                redo()
            } send: {
                send(grid: selectedDraft!.grid)
            }
            Button {
                withAnimation {
                    scrollToArtView()
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
    DrawView(selectedDraftId: .constant(nil)) {}
}
