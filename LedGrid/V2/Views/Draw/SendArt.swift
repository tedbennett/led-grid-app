//
//  SendArt.swift
//  LedGrid
//
//  Created by Ted Bennett on 13/02/2024.
//

import SwiftData
import SwiftUI

struct SendArt: View {
    @State private var presentModal = false
    @State private var feedback = false

    var handleSendArt: ([String]) async -> Void

    var body: some View {
        Button {
            if LocalStorage.user != nil {
                presentModal.toggle()
            } else {
                NotificationCenter.default.post(name: .showSignIn, object: true)
            }
            feedback.toggle()
        } label: {
            Image(systemName: "paperplane").font(.title).padding(5)
        }.buttonStyle(StdButton())
            .sheet(isPresented: $presentModal, content: {
                SelectFriends { friends in
                    await handleSendArt(friends)
                    presentModal = false
                }
                .presentationDetents([.medium, .large])
            }).sensoryFeedback(.impact(flexibility: .solid), trigger: feedback)
            .accessibilityLabel("send-button")
    }
}

struct SelectFriends: View {
    @Query var friends: [Friend] = []
    @State var selectedFriends: Set<String> = Set()
    @State var isLoading = false
    @Environment(\.dismiss) var dismiss
    var handleSendArt: ([String]) async -> Void

    func isSelected(_ friend: Friend) -> Bool {
        selectedFriends.contains(friend.id)
    }

    func toggleFriend(_ friend: Friend) {
        if selectedFriends.remove(friend.id) == nil {
            selectedFriends.insert(friend.id)
        }
    }

    func sendArt() {
        isLoading = true
        Task {
            await handleSendArt(Array(selectedFriends))
            await MainActor.run {
                isLoading = false
            }
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("Select Friends").font(.custom("FiraMono Nerd Font", size: 24))
                Spacer()
            }
            .padding(.top, 12)
            if friends.isEmpty {
                Spacer()
                Text("You have no friends :(").font(.caption).foregroundStyle(.secondary)
                    .padding(.bottom, 5)
                Button {
                    dismiss()
                    NotificationCenter.default.post(name: .navigate, object: "friends")
                } label: {
                    Text("Add Friends")
                }
                .foregroundStyle(.primary)
                .padding(8)
                .padding(.horizontal, 9)
                .background(.placeholder.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                Spacer()

            } else {
                ScrollView {
                    ForEach(friends) { friend in
                        let username = "@\(friend.username)"
                        Button {
                            toggleFriend(friend)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(friend.name ?? username)
                                    if friend.name != nil {
                                        Text(username).font(.caption).italic().foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Image(systemName: "checkmark").opacity(isSelected(friend) ? 1 : 0)
                            }.foregroundStyle(isSelected(friend) ? .primary : .primary)
                                .padding(15)
                                .background(isSelected(friend) ? .tertiary : .quinary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }.buttonStyle(.plain)
                    }
                }
                Button {
                    sendArt()
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Send").font(.custom("FiraMono Nerd Font", size: 24))
                        }
                    }
                }.foregroundStyle(.primary)
                    .padding(14)
                    .padding(.horizontal, 20)
                    .background(.placeholder.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .disabled(selectedFriends.isEmpty || isLoading)
                    .opacity(selectedFriends.isEmpty || isLoading ? 0.5 : 1)
            }
        }
        .padding()
    }
}

#Preview {
    SendArt { _ in }.modelContainer(PreviewStore.container)
}
