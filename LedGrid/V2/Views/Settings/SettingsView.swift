//
//  SettingsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/01/2024.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    var user: APIUser

    @State private var username: String = ""
    @State private var name: String = ""

    @State private var isLoading = false

    var canSave: Bool {
        username.trimmingCharacters(in: .whitespaces) != user.username.trimmingCharacters(in: .whitespaces) ||
            name.trimmingCharacters(in: .whitespaces) != user.name?.trimmingCharacters(in: .whitespaces)
    }

    func updateUser() {
        isLoading = true
        Task.detached {
            do {
                try await API.updateMe(name: name, username: username, image: nil, plus: nil)
                let user = try await API.getMe()
                LocalStorage.user = user
            } catch {
                logger.error("\(error.localizedDescription)")
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }

    var body: some View {
        Form {
            Section("Your Details") {
                TextField("Username", text: $username)
                TextField("Name", text: $name)
                Text(user.email).foregroundStyle(.gray)
            }
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                updateUser()
            } label: {
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
            }.disabled(canSave || isLoading)
        }.onAppear {
            if username != "" { return }
            username = user.username
        }
    }
}

#Preview {
    SettingsView(user: APIUser.example)
}

extension APIUser {
    static var example = APIUser(createdAt: .now, email: "email@email.com", id: UUID().uuidString, plus: false, username: "username")
}
