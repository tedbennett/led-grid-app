//
//  SettingsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/01/2024.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(ToastManager.self) var toastManager
    var user: APIUser

    @State private var username: String = ""
    @State private var name: String = ""

    @State private var isLoading = false

    @State private var usernameOK = true
    @State private var showDeleteAlert = false

    var canSave: Bool {
        // Invalid/Taken username
        if !usernameOK { return false }
        // Empty name or username
        if username.isEmpty || name.isEmpty {
            return false
        }
        // Username and name have not changed
        return username.trimmingCharacters(in: .whitespaces) != user.username.trimmingCharacters(in: .whitespaces) ||
            name.trimmingCharacters(in: .whitespaces) != user.name?.trimmingCharacters(in: .whitespaces)
    }

    func updateUser() {
        isLoading = true
        Task.detached {
            do {
                try await API.updateMe(name: name, username: username, image: nil, plus: nil)
                let user = try await API.getMe()
                LocalStorage.user = user
                await MainActor.run {
                    isLoading = false
                    toastManager.toast = .profileUpdated
                }
            } catch {
                logger.error("\(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                    toastManager.toast = .errorOccurred
                }
            }
        }
    }

    func deleteUser() {
        Task {
            try await API.deleteMe()
            await MainActor.run {
                toastManager.toast = .logoutSuccess
                NotificationCenter.default.post(name: .logout, object: nil)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    var body: some View {
        Form {
            Section("Username") {
                UsernameEditor(initial: user.username, username: $username, ok: $usernameOK)
            }
            Section("Full Name") {
                TextField("Name", text: $name)
            }
            Section("Email") {
                Text(user.email).foregroundStyle(.gray)
            }
            Section("Account") {
                Button {
                    NotificationCenter.default.post(name: .logout, object: nil)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Logout")
                }

                Button {
                    showDeleteAlert.toggle()
                } label: {
                    Text("Delete Account")
                        .tint(.red)
                }
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
            }.disabled(!canSave || isLoading)
        }.onAppear {
            name = user.name ?? ""
            username = user.username
        }
        .alert("Delete account?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) { deleteUser() }
        } message: {
            Text("This action cannot be reversed.")
        }
    }
}

#Preview {
    SettingsView(user: APIUser.example).environment(ToastManager())
}

extension APIUser {
    static var example = APIUser(createdAt: .now, email: "email@email.com", id: UUID().uuidString, plus: false, username: "username")
}
