//
//  UsernameInput.swift
//  LedGrid
//
//  Created by Ted Bennett on 22/02/2024.
//

import Combine
import SwiftUI

struct UsernameInput: View {
    @State private var username = ""
    @State private var status: UsernameStatus = .notChanged

    var onSubmit: (String) -> Void
    let usernamePublisher = PassthroughSubject<String, Never>()
    func check(username: String) {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            status = .notChanged
            return
        }

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

    func clean(_ username: String) -> String {
        return String(username.filter { $0.isLetter || $0.isNumber || $0 == "_" }.prefix(20))
    }

    var body: some View {
        VStack {
            Spacer()
            Text("You're signed up!")
                .font(.title2)
            Text("Now pick a username")
                .padding(.bottom, 20)
            HStack {
                Text("@")
                    .padding(.trailing, -5)
                TextField("Choose a username", text: $username)
                    .textInputAutocapitalization(.never)
                    .debounce(username, publisher: usernamePublisher) { _ in
                        check(username: username)
                    }
                    .onChange(of: username) {
                        status = .loading
                        username = clean(username)
                    }
                statusImage
            }.font(.title3)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(.placeholder.opacity(0.4)))
                .padding(.horizontal, 20)
            Button {
                onSubmit(username)
            } label: {
                Text("Continue")
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .padding(8)
                    .padding(.horizontal, 9)
                    .background(.placeholder.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(status == .available ? 1 : 0.8)
            }
            .disabled(status != .available)
            .padding(20)
            Spacer()
        }
    }
}

#Preview {
    UsernameInput { _ in }
}
