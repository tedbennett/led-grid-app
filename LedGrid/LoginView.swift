//
//  LoginView.swift
//  LedGrid
//
//  Created by Ted on 27/07/2022.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Binding var loggedIn: Bool
    @State private var showSignInAlert = false
    var body: some View {
        VStack {
            Spacer()
            Text("Sign in to begin")
            SignInWithAppleButton(.signUp) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authResults):
                    Task {
                        do {
                            try await NetworkManager.shared.handleSignInWithApple(authorization: authResults)
                            await MainActor.run {
                                loggedIn = true
                            }
                        } catch {
                            print("Sign in failed: \(error.localizedDescription)")
                            await MainActor.run {
                                showSignInAlert = true
                            }
                        }
                    }
                case .failure(let error):
                    print("Authorisation failed: \(error.localizedDescription)")
                    showSignInAlert = true
                }
            }
            Spacer()
        }.navigationTitle("Welcome to Pixee")
            .alert("Failed to sign up", isPresented: $showSignInAlert) {
                Button("OK") { }
            } message: {
                Text("Please try again later.")
            }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loggedIn: .constant(false))
    }
}
