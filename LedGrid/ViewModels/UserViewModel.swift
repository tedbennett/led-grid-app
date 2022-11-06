//
//  UserViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 07/10/2022.
//

import SwiftUI

class UserViewModel: ObservableObject {
    @Published var user: MUser? = Utility.user {
        didSet {
            Utility.user = user
        }
    }
    
    func updateUser(fullName: String) async {
        if user == nil { return }
        user?.fullName = fullName
        Task {
            do {
                try await NetworkManager.shared.updateUser(
                    id: user!.id,
                    fullName: fullName,
                    givenName: user!.givenName ?? "",
                    email: user!.email ?? "")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func logout() {
        AuthService.logout()
        user = nil
        Utility.clear()
        Task {
            await PixeeProvider.removeAllArtAndUsers()
        }
    }
    
    func deleteAccount() {
        Task {
            do {
                try await NetworkManager.shared.deleteAccount()
            } catch {
                print("Error deleting account: \(error.localizedDescription)")
            }
        }
        logout()
    }
}
