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
    @State private var tab = DrawingsTab.received

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \DraftDrawing.updatedAt, order: .reverse, animation: .bouncy) var drafts: [DraftDrawing] = []
    @Query(sort: \ReceivedDrawing.createdAt, order: .reverse, animation: .bouncy) var received: [ReceivedDrawing] = []
    @Query(sort: \SentDrawing.createdAt, order: .reverse, animation: .bouncy) var sent: [SentDrawing] = []
    @Query var friends: [Friend] = []

    @State private var feedback = false

    let scrollToDrawView: () -> Void

    func scrollUp() {
        feedback.toggle()
        withAnimation {
            scrollToDrawView()
        }
    }

    func selectDraft(at index: Int) {
        do {
            let draft = drafts[index]
            draft.updatedAt = .now
            try modelContext.save()
            scrollUp()
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }

    var noDrawingsMessage: String {
        if LocalStorage.user == nil {
            return "Sign in to send and receive drawings"
        }
        switch tab {
        case .sent: return "No drawings sent yet"
        case .received: return "No drawings received yet"
        case .drafts: return "No drafts"
        }
    }

    @ViewBuilder
    var noDrawingsButton: some View {
        if LocalStorage.user == nil {
            Button {
                feedback.toggle()
                NotificationCenter.default.post(name: Notification.Name.showSignIn, object: nil)
            } label: {
                Text("Sign In")
            }
        } else if friends.isEmpty {
            NavigationLink {
                FriendsView(user: LocalStorage.user!)
            } label: {
                Text("Add Friends")
            }
        } else {
            Button {
                scrollUp()
            } label: {
                Text("Create Drawings")
            }
        }
    }

    func selectReceived(at index: Int) {
        feedback.toggle()
        do {
            // TODO: Move to api
            let received = received[index]
            received.opened = true
            try modelContext.save()
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }

    func copy(drawing: any Drawing) {
        tab = .drafts
        do {
            let draft = DraftDrawing(size: .small)
            draft.grid = drawing.grid
            modelContext.insert(draft)
            try modelContext.save()
        } catch {
            logger.error("\(error.localizedDescription)")
        }
        scrollUp()
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
            DrawingsHeader(tab: $tab) {
                scrollUp()
            }
            if drawings.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Text(noDrawingsMessage).font(.caption).foregroundStyle(.secondary)
                    noDrawingsButton
                        .foregroundStyle(.primary)
                        .padding(8)
                        .padding(.horizontal, 9)
                        .background(.placeholder.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
            } else {
                DrawingList(drawings: drawings) { drawing, index in
                    switch tab {
                    case .drafts:
                        DraftDrawingView(drawing: drawing) {
                            selectDraft(at: index)
                        }
                    case .received:
                        ReceivedDrawingView(drawing: drawing) {
                            selectReceived(at: index)
                        } onCopy: {
                            copy(drawing: drawing)
                        }
                    case .sent:
                        SentDrawingView(drawing: drawing) {
                            copy(drawing: drawing)
                        }
                    }
                }
            }
        }.sensoryFeedback(.impact(flexibility: .solid), trigger: feedback)
    }
}

struct ArtViewPreview: PreviewProvider {
    static var previews: some View {
        DrawingsView {}
            .modelContainer(PreviewStore.container)
    }
}

struct SentDrawingView: View {
    var drawing: any Drawing
    var onSelect: () -> Void

    var body: some View {
        GridView(grid: drawing.grid)
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        Color.gray.opacity(0.2), lineWidth: 1
                    )
            )
            .font(.title)
            .padding(1)
            .contextMenu(ContextMenu(menuItems: {
                Button {
                    onSelect()
                } label: {
                    Text("Copy to draft")
                }
            }))
    }
}

struct ReceivedDrawingView: View {
    var drawing: any Drawing
    var onSelect: () -> Void
    var onCopy: () -> Void

    var body: some View {
        VStack(alignment: .center) {
            GridView(grid: drawing.grid)
                .aspectRatio(contentMode: .fit)
                .blur(radius: drawing.opened ? 0 : 20)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color.gray.opacity(0.2), lineWidth: 1
                        )
                )
                .overlay(
                    Image(systemName: "eye")
                        .foregroundStyle(.gray)
                        .opacity(drawing.opened ? 0 : 1))
                .font(.title)
                .padding(1)
                .contextMenu(ContextMenu(menuItems: {
                    Button {
                        onCopy()
                    } label: {
                        Text("Copy to draft")
                    }
                }))
                .onTapGesture {
                    onSelect()
                }
            if let friend = drawing.sender {
                Text("From \(friend.name ?? friend.username)").foregroundStyle(.secondary).italic().font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct DraftDrawingView: View {
    var drawing: any Drawing
    var onSelect: () -> Void

    var body: some View {
        GridView(grid: drawing.grid)
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        Color.gray.opacity(0.2), lineWidth: 1
                    )
            )
            .font(.title)
            .padding(1)
            .onTapGesture {
                onSelect()
            }
    }
}
