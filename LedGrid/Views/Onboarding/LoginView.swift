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
    @ObservedObject var viewModel = LoginViewModel()
    
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
                if !viewModel.isSigningIn {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        Task {
                            let success = await viewModel.handleSignIn(result: result)
                            await MainActor.run {
                                loggedIn = success
                            }
                        }
                        
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
            
            .onAppear {
                if viewModel.shouldLogin() { loggedIn = true }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loggedIn: .constant(false))
    }
}

