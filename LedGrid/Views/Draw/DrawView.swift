//
//  DrawView.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/06/2023.
//

import SwiftData
import SwiftUI

func initialColor() -> Color {
    let colors = [Color.green, Color.blue, Color.red, Color.yellow, Color.orange, Color.purple]
    let index = Int.random(in: 0 ..< colors.count)
    return colors[index]
}

struct DrawView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ToastManager.self) var toastManager
    @Query(sort: \DraftDrawing.updatedAt, order: .reverse) var drafts: [DraftDrawing] = []
    @Query(filter: #Predicate<ReceivedDrawing> {
        !$0.opened
    }) var receivedDrawing: [ReceivedDrawing] = []

    let scrollToArtView: () -> Void

    @State private var isSending = false

    @State private var color = initialColor()
    @State private var prevColor: Color?
    @State private var recentColors: [Color] = []

    @State private var undoStack: [Grid] = []
    @State private var redoStack: [Grid] = []

    func handleGridChange(_ newGrid: Grid) {
        pushUndo(newGrid)
        if color != prevColor {
            if let prevColor = prevColor, !recentColors.contains(where: { $0.hex == prevColor.hex }) {
                var recents = Array(recentColors.prefix(4))
                recents.insert(prevColor, at: 0)
                withAnimation {
                    recentColors = recents
                }
            }
            prevColor = color
        }
    }

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

    func send(_ grid: Grid, to friends: [String]) async {
        do {
            try await DataLayer().sendDrawing(grid, to: friends)
            await MainActor.run {
                toastManager.toast = .sentDrawingSuccess
            }
        } catch {
            logger.error("\(error.localizedDescription)")
            await MainActor.run {
                toastManager.toast = .sentDrawingFailed
            }
        }
    }

    var body: some View {
        VStack {
            HeaderView()
                .padding(.top, 50)
                .padding(.horizontal, 20)
            Spacer()

            let selectedDraft = drafts.first

            if let art = selectedDraft {
                CanvasView(art: art, color: color) { handleGridChange($0) }

            } else {
                Spinner()
                    .onAppear {
                        modelContext.insert(DraftDrawing(size: .small, color: colorScheme == .dark ? Grid.black : Grid.white))
                    }
            }
            Spacer()
            RecentColors(colors: recentColors, selectColor: {
                color = $0
            })
            BottomBarView(color: $color, canUndo: !undoStack.isEmpty, canRedo: !redoStack.isEmpty) {
                undo()
            } redo: {
                redo()
            } send: { friends in
                await send(selectedDraft!.grid, to: friends)
            }
            Button {
                withAnimation {
                    scrollToArtView()
                }
            } label: {
                HStack {
                    if !receivedDrawing.isEmpty {
                        Circle().fill(Color.red).frame(width: 10, height: 10)
                    }
                    Text("View Drawings")
                    Image(systemName: "chevron.down")
                }.foregroundStyle(.primary)
                    .padding(8)
                    .padding(.horizontal, 9)
                    .background(.placeholder.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 10)
        }
    }
}

#Preview {
    DrawView {}
        .modelContainer(PreviewStore.container)
        .environment(ToastManager())
}
