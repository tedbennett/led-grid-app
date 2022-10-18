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
    
    var friendsModel = FriendsModel()
    
    func requestNotificationPermissions() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        Task {
            do {
                _ = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } catch {
                print("Failed to register for notifications: \(error.localizedDescription)")
            }
        }
    }
    
    func handleSignIn(result: (Result<ASAuthorization, Error>)) async -> Bool {
        switch result {
        case .success(let authResults):
            await MainActor.run {
                isSigningIn = true
            }
                do {
                    Utility.user = try await NetworkManager.shared.handleSignInWithApple(authorization: authResults)
                    try await PixeeProvider.fetchArtAndFriends()
                    requestNotificationPermissions()
                    await MainActor.run {
                        isSigningIn = false
                    }
                    return true
                } catch {
                    print("Sign in failed: \(error.localizedDescription)")
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
            requestNotificationPermissions()
            return true
        } else {
            AuthService.logout()
            return false
        }
    }
}
