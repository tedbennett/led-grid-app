//
//  SettingsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
        
    var body: some View {
        NavigationView {
            VStack {
                SignInWithAppleButton(.signUp) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        Task {
                            try? await NetworkManager.shared.handleSignInWithApple(authorization: authResults)
                        }
                    case .failure(let error):
                        print("Authorisation failed: \(error.localizedDescription)")
                    }
                }
            }.navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
