//
//  LoginViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 03/10/2022.
//

import Foundation
import AuthenticationServices

class LoginViewModel: ObservableObject {
    
    @Published var showSignInAlert = false
    @Published var isSigningIn = false
    @Published var loggedIn: Bool
    
    init(loggedIn: Bool) {
        self.loggedIn = loggedIn
        
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: Notifications.logout, object: nil)
    }
    
    @objc func logout() {
        DispatchQueue.main.async {
            self.loggedIn = false
        }
    }
    
    var friendsModel = FriendsModel()
    
    func handleSignIn(result: (Result<ASAuthorization, Error>)) async -> Bool {
        switch result {
        case .success(let authResults):
            await MainActor.run {
                isSigningIn = true
            }
            do {
                let user = try await NetworkManager.shared.handleSignInWithApple(authorization: authResults)
                Utility.user = user
                try await PixeeProvider.fetchAllData()
                await MainActor.run {
                    isSigningIn = false
                }
                return true
            } catch {
                print("Sign in failed: \(error.localizedDescription)")
                Utility.user = nil
            }
        case .failure(let error):
            print("Authorisation failed: \(error.localizedDescription)")
        }
        await MainActor.run {
            showSignInAlert = true
            isSigningIn = false
        }
        return false
    }
    
    func shouldLogin() -> Bool {
        if AuthService.canRenew() && Utility.user?.id != nil {
            return true
        } else {
            AuthService.logout()
            return false
        }
    }
}
