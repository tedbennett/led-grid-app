//
//  UsernameEditor.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import Combine
import SwiftUI

enum UsernameStatus {
    case available
    case notAvailable
    case loading
    case notChanged
}

struct UsernameEditor: View {
    var initial: String
    @Binding var username: String
    @State private var status: UsernameStatus = .notChanged {
        didSet {
            ok = status == .available || status == .notChanged
        }
    }

    @Binding var ok: Bool

    let usernamePublisher = PassthroughSubject<String, Never>()
    func check(username: String) {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        // Same as initial value
        guard username != initial.trimmingCharacters(in: .whitespaces) else {
            status = .notChanged
            return
        }
        status = .loading

        Task {
            do {
                let available = try await API.checkUsername(trimmed)
                await MainActor.run {
                    status = available ? .available : .notAvailable
                }
            } catch {
                print(error)
                await MainActor.run {
                    status = .notAvailable
                }
            }
        }
    }

    var statusImage: some View {
        Group {
            switch status {
            case .available:
                Image(systemName: "checkmark")
            case .notAvailable:
                Image(systemName: "xmark")
            case .loading:
                ProgressView()
            case .notChanged:
                EmptyView()
            }
        }
    }

    var body: some View {
        HStack {
            TextField("Username", text: $username)
                .onChange(of: username) {
                    check(username: username)
                }
            statusImage
        }
        .onAppear {
            username = initial
            status = .notChanged
        }
    }
}

#Preview {
    UsernameEditor(initial: "Username", username: .constant("Username"), ok: .constant(true))
}
