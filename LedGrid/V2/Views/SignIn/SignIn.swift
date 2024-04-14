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
    @Environment(ToastManager.self) var toastManager

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
                    LocalStorage.fetchDate = nil

                    await MainActor.run {
                        if result.created {
                            state = .changeUsername
                        } else {
                            NotificationCenter.default.post(name: .handleSignIn, object: nil)

                            requestNotifications()
                            dismiss()
                        }
                    }
                } catch {
                    logger.error("\(error.localizedDescription)")
                    toastManager.toast = .signInFailed
                    dismiss()
                }
            }
        case .failure(let failure):
            logger.error("\(failure)")
            toastManager.toast = .signInFailed
            dismiss()
        }
    }

    func requestNotifications() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in
                }
            )
        UIApplication.shared.registerForRemoteNotifications()
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
                .opacity(state == .notStarted ? 1 : 0)
            }
            if state == .changeUsername {
                UsernameInput { username in
                    Task {
                        do {
                            try await API.updateMe(name: nil, username: username, image: nil, plus: nil)
                            await MainActor.run {
                                toastManager.toast = .signInSuccess
                                NotificationCenter.default.post(name: .handleSignIn, object: nil)
                                requestNotifications()
                                dismiss()
                            }
                        } catch {
                            // TODO: Show error
                            dismiss()
                        }
                    }
                }
            } else {
                Spacer()
                Text("SIGN IN")
                    .font(.custom("FiraMono Nerd Font", size: 32))

                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: {
                    handleSignIn(result: $0)
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .cornerRadius(15)
                .centered(.horizontal)
                .frame(height: 55)
                .disabled(state != .notStarted)
                Text("Sign in or create an account to share drawings with your friends!")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 10)
                Spacer()
            }
        }
        .padding(.horizontal, 30)
        .navigationBarBackButtonHidden(state == .signingIn)
    }
}

#Preview {
    SignIn()
}
