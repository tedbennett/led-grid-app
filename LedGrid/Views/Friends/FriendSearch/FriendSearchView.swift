//
//  FriendSearchView.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import Combine
import SwiftData
import SwiftUI

struct FriendSearchView: View {
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var results: [APIUser] = []
    @Query private var requests: [FriendRequest] = []
    @Query private var friends: [Friend] = []
    @Environment(ToastManager.self) var toastManager


    let searchTextPublisher = PassthroughSubject<String, Never>()

    func searchUsers(by term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            results = []
            return
        }
        isLoading = true
        Task {
            do {
                let users = try await API.searchUsers(by: trimmed)
                await MainActor.run {
                    results = users
                    isLoading = false
                }
            } catch {
                print(error)
                await MainActor.run {
                    results = []
                    isLoading = false
                }
            }
        }
    }

    func sendFriendRequest(to userId: String) {
        Task {
            do {
                try await DataLayer().sendFriendRequest(to: userId)
                await MainActor.run {
                    toastManager.toast = .friendInviteSent
                }
            } catch {
                print(error)
                await MainActor.run {
                    toastManager.toast = .errorOccurred
                }
            }
        }
    }

    func addedFriend(_ user: APIUser) -> Bool {
        requests.contains { $0.sent && $0.status == .sent && $0.userId == user.id } || friends.contains { $0.id == user.id }
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .tint(.secondary)
                TextField("Search for username", text: $searchText)
                    .padding(.vertical, 10)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .tint(.secondary)
                    }
                }
            }.padding(.horizontal, 10)
                .background(.placeholder.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            if searchText.isEmpty {
                Spacer()
                Text("Start typing to search for friends").foregroundStyle(.secondary)
                    .font(.callout)
                Spacer()
            } else if results.isEmpty {
                Spacer()
                Text(isLoading ? "Searching..." : "No users found").foregroundStyle(.secondary)
                    .font(.callout)
                Spacer()
            } else {
                ScrollView {
                    ForEach(results) { user in
                        FriendCard(friend: user, added: addedFriend(user)) {
                            sendFriendRequest(to: $0)
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
        .debounce(searchText, publisher: searchTextPublisher) { search in
            searchUsers(by: search)
        }
        .onChange(of: searchText) { search, _ in
            if search.isEmpty {
                results = []
            } else {
                isLoading = true
            }
        }
        .padding(10)
    }
}

#Preview {
    FriendSearchView()
}

extension APIUser: Identifiable {}
