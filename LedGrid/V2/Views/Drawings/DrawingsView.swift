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
    @Query var friends: [Friend] = []

    @State private var feedback = false

    let scrollToDrawView: () -> Void

    @State private var appeared = false

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
            print(error)
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
                DrawingList(drawings: drawings) { index in
                    guard tab == .drafts else {
                        return
                    }
                    selectDraft(at: index)
                }.onAppear {
                    if !received.isEmpty && !appeared {
                        tab = .received
                        appeared = true
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
