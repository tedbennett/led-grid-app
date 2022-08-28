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
    
    func handleSignIn(result: (Result<ASAuthorization, Error>)) {
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
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                SpinningImageView().padding(.bottom, 10)
                Spacer()
                VStack {
                IconListItemView(image: "square.grid.2x2", title: "Draw Pixel Art", subtitle: "Create beautiful art with fluid gestures")
                IconListItemView(image: "paperplane.circle", title: "Send it to your friends", subtitle: "Easily add friends by just sharing a link")
                IconListItemView(image: "star.circle", title: "More Features", subtitle: "Pixee Plus lets you create more detailed, dynamic art")
                }.padding(.horizontal, 10)
                Spacer()
                if !isSigningIn {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleSignIn(result: result)
                    }.frame(width: 250, height: 80).overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white, lineWidth: 2)
                    ).clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Spinner().font(.title).frame(width: 250, height: 80).overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white, lineWidth: 2)
                    )
                }
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

