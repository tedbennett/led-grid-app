//
//  SignIn.swift
//  LedGrid
//
//  Created by Ted Bennett on 17/02/2024.
//

import AuthenticationServices
import SwiftUI

struct SignIn: View {
    @State private var isSigningIn = false
    @Environment(\.colorScheme) var colorScheme

    var onSignIn: () -> Void

    func handleSignIn(result: Result<ASAuthorization, Error>) {
        isSigningIn = true
        Task {
            let success = true // API call here
            if success {
                onSignIn()
            } else {
                await MainActor.run {
                    isSigningIn = false
                }
            }
        }
    }

    var body: some View {
        SignInWithAppleButton { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: {
            handleSignIn(result: $0)
        }.signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .cornerRadius(15)
            .centered(.horizontal)
            .frame(height: 55)
            .padding(.horizontal, 30)
    }
}

#Preview {
    SignIn {}
}
