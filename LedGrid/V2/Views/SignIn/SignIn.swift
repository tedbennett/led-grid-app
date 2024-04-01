//
//  SignIn.swift
//  LedGrid
//
//  Created by Ted Bennett on 17/02/2024.
//

import AuthenticationServices
import SwiftUI

enum SignInState {
    case notStarted
    case signingIn
    case changeUsername
}

struct SignIn: View {
    @State private var state = SignInState.notStarted
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    func importUserData() async throws {
        let container = Container()
        let friends = try await API.getFriends()
        // TODO: Ensure we're upserting here
        try await container.insertFriends(friends)

        let receivedDrawings = try await API.getReceivedDrawings(since: nil)
        try await container.insertReceivedDrawings(receivedDrawings)
        let sentDrawings = try await API.getSentDrawings(since: nil)
        try await container.insertSentDrawings(sentDrawings)

        let user = try await API.getMe()
        LocalStorage.user = user
        LocalStorage.fetchDate = .now
    }

    func handleSignIn(result: Result<ASAuthorization, Error>) {
        state = .signingIn
        switch result {
        case .success(let success):
            let credential = success.credential as! ASAuthorizationAppleIDCredential
            let code = String(data: credential.authorizationCode!, encoding: .utf8) ?? ""
            Task {
                do {
                    let result = try await API.signIn(code: code, id: credential.user, name: credential.fullName?.formatted() ?? "", email: credential.email)
                    Keychain.set(result.token, for: .apiKey)

                    await MainActor.run {
                        if result.created {
                            state = .changeUsername
                        } else {
                            NotificationCenter.default.post(name: Notification.Name.handleSignIn, object: nil)
                            dismiss()
                        }
                    }
                } catch {
                    logger.error("\(error.localizedDescription)")
                }
            }
        case .failure(let failure):
            logger.error("\(failure)")
            Toast.signInFailed.present()
            dismiss()
        }
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(StdButton())
                .disabled(state != .notStarted)
            }
            if state == .changeUsername {
                UsernameInput { username in
                    Task {
                        try await API.updateMe(name: nil, username: username, image: nil, plus: nil)
                        await MainActor.run {
                            Toast.signInSuccess.present()
                            dismiss()
                        }
                    }
                }
            } else {
                Spacer()
                SignInWithAppleButton { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: {
                    handleSignIn(result: $0)
                }.signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .cornerRadius(15)
                    .centered(.horizontal)
                    .frame(height: 55)
                    .padding(.horizontal, 30)
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(state == .signingIn)
    }
}

#Preview {
    SignIn()
}
