//
//  SignInView.swift
//  LedGrid
//
//  Created by Ted Bennett on 14/11/2022.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @State private var signingIn = false
    @State private var showSignInAlert = false
    @ObservedObject var viewModel: LoginViewModel
    var onSignIn: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        VStack {
            Spacer()
            SpinningImageView()
                .fadeInWithDelay(0.3)
            Spacer()
            VStack {
                Text("Pixee is the app that lets you create beautiful pixel art and share it with your friends")
                    .font(.system(size: 20, design: .rounded).weight(.medium))
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .fadeInWithDelay(0.7)
            }
            Spacer()
            VStack {
                if !signingIn {
                    SignInWithAppleButton { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        signingIn = true
                        Task {
                            let success = await viewModel.handleSignIn(result: result)
                            if success {
                                onSignIn()
                            } else {
                                await MainActor.run {
                                    showSignInAlert = true
                                    signingIn = false
                                }
                            }
                        }
                    }.signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        .cornerRadius(15)
                        .centered(.horizontal)
                        .frame(height: 55)
                        .padding(.horizontal, 30)
                } else {
                    Button {
                    } label: {
                        Spinner()
                    }.buttonStyle(LargeButton())
                    .padding(.horizontal, 35)
                    .disabled(true)
                }
                
                Text("Sign in to get started")
                    .foregroundColor(.gray)

            }
            .fadeInWithDelay(1.0)
                .padding(.bottom, 60)
        }.alert("Failed to sign up", isPresented: $showSignInAlert) {
            Button("OK") { }
        } message: {
            Text("Please try again later.")
        }
    }
}


struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(viewModel: LoginViewModel(loggedIn: false)) {
            
        }
    }
}
