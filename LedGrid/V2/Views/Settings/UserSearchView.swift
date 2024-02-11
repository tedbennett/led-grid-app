//
//  UserSearchView.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import Combine
import SwiftData
import SwiftUI

struct UserSearchView: View {
    @State private var searchText = ""
    @State private var results: [APIUser] = []
    @Query private var sentRequests: [FriendRequest] = []

    let searchTextPublisher = PassthroughSubject<String, Never>()

    init() {
        let sent = FriendRequestStatus.sent.rawValue

        let filter = #Predicate<FriendRequest> { request in
            request.status.rawValue == sent && request.sent
        }
        _sentRequests = Query(filter: filter)
    }

    func searchUsers(by term: String) async {
        do {
            let users = try await API.searchUsers(by: term)
            await MainActor.run {
                results = users
            }
        } catch {
            print(error)
        }
    }

    func sendFriendRequest(to userId: String) async {
        Task {
            do {
                try await API.sendFriendRequest(to: userId)
            } catch {
                print(error)
            }
        }
    }

    var body: some View {
        List {
            ForEach(results) { user in
                UserCard(user)
            }
        }
        .searchable(text: $searchText)
        .debounce(searchText, publisher: searchTextPublisher) { search in
            Task {
                await searchUsers(by: search)
            }
        }
    }
}

#Preview {
    UserSearchView()
}

extension APIUser: Identifiable {}
