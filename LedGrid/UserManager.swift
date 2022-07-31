//
//  UserManager.swift
//  LedGrid
//
//  Created by Ted on 29/07/2022.
//

import Foundation
import NotificationCenter

class UserManager: ObservableObject {
    static var shared = UserManager()
    private init() {}
    @Published var user: User? = Utility.user {
        didSet {
            Utility.user = user
        }
    }
    @Published var friends: [User] = Utility.friends {
        didSet {
            Utility.friends = friends
        }
    }
    
    func setUser(_ user: User) {
        self.user = user
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
    
    // returns false if already a friend
    func addFriend(id: String) async throws -> Bool {
        if friends.contains(where: { $0.id == id }) {
            return false
        }
        let user = try await NetworkManager.shared.getUser(id: id)
        await MainActor.run {
            friends.append(user)
        }
        return true
    }
    
    func removeFriend(id: String) {
        friends = friends.filter { $0.id != id }
    }
    
    func requestNotificationPermissions() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        )
    }
}
