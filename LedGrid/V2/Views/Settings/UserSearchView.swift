//
//  UserSearchView.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import Combine
import SwiftUI

struct UserSearchView: View {
    @State private var searchText = ""
    @State private var results: [APIUser] = []

    let searchTextPublisher = PassthroughSubject<String, Never>()

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
