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
    @State private var isSigningIn = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                SpinningImageView()
                Spacer()
                Text("Send pixel art to your friends!").padding()
                if !isSigningIn {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        isSigningIn = true
                        Task {
                            do {
                                try await NetworkManager.shared.handleSignInWithApple(authorization: authResults)
                                UserManager.shared.requestNotificationPermissions()
                                await GridManager.shared.refreshReceivedGrids(markOpened: true)
                                await GridManager.shared.refreshSentGrids()
                                await UserManager.shared.refreshFriends()
                                await MainActor.run {
                                    isSigningIn = false
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
                }.frame(width: 250, height: 80).overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white, lineWidth: 2)
                )
                } else {
                    Spinner().font(.title).frame(width: 250, height: 80).overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white, lineWidth: 2)
                    )
                }
                Text("Sign in to get started").padding()
                Spacer()
            }
            .navigationTitle("Welcome to Pixee")
            .alert("Failed to sign up", isPresented: $showSignInAlert) {
                Button("OK") { }
            } message: {
                Text("Please try again later.")
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loggedIn: .constant(false))
    }
}

struct SpinningImageView: View {
    @State var isAnimating = false
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 20.0)
            .repeatForever(autoreverses: false)
    }
    var body: some View {
        VStack(spacing: -7) {
            HStack(spacing: -15) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 96, weight: .thin))
                    .padding(0)
                
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 96, weight: .thin))
                    .padding(0)
            }
            HStack(spacing: -15) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 96, weight: .thin))
                    .padding(0)
                
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 96, weight: .thin))
                    .padding(0)
            }
            
        }
        .rotationEffect(Angle(degrees: isAnimating ? 360: 0 ))
        
        .task {
            withAnimation(self.foreverAnimation) {
                isAnimating = true
            }
        }
    }
}

struct Spinner: View {
    @State var isAnimating = false
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 1.3)
            .repeatForever(autoreverses: false)
    }
    var body: some View {
        Image(systemName: "square.grid.2x2")
            .padding(0)
        
        .rotationEffect(Angle(degrees: isAnimating ? 360: 0 ))
        
        .task {
            withAnimation(self.foreverAnimation) {
                isAnimating = true
            }
        }
    }
}
