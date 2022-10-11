////
////  UserManager.swift
////  LedGrid
////
////  Created by Ted on 29/07/2022.
////
//
//import Foundation
//import NotificationCenter
//
//class UserManager: ObservableObject {
//    static var shared = UserManager()
//    private init() {
//        Task {
//           await refreshFriends()
//        }
//    }
//    
//    @Published var user: User? = Utility.user {
//        didSet {
//            Utility.user = user
//        }
//    }
//    @Published var friends: [User] = Utility.friends {
//        didSet {
//            Utility.friends = friends
//        }
//    }
//    
//    func updateUser(fullName: String) async {
//        if user == nil { return }
//        user?.fullName = fullName
//        Task {
//            do {
//                try await NetworkManager.shared.updateUser(
//                    id: user!.id,
//                    fullName: fullName,
//                    givenName: user!.givenName ?? "",
//                    email: user!.email ?? "")
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
//    
//    func getInitials(for id: String) -> String? {
//        if user?.id == id {
//            return user?.fullName?
//                .split(separator: " ")
//                .map { $0.prefix(1) }
//                .joined()
//                .uppercased()
//        }
//        return friends.first { $0.id == id}?
//            .fullName?
//            .split(separator: " ")
//            .map { $0.prefix(1) }
//            .joined()
//            .uppercased()
//    }
//    
//    func getUser(id: String) -> User? {
//        friends.first { $0.id == id}
//    }
//    
//    func refreshFriends() async {
//        do {
//            let friends = try await getFriends()
//            await MainActor.run {
//                self.friends = friends
//
//            }
//        } catch {
//            print("Failed to fetch friends: \(error.localizedDescription)")
//        }
//    }
//    
//    func getFriends() async throws -> [User] {
//        return try await NetworkManager.shared.getFriends()
//    }
//    
//    // returns false if already a friend
//    func addFriend(id: String) async throws -> Bool {
//        if friends.contains(where: { $0.id == id }) {
//            return false
//        }
//        _ = try await NetworkManager.shared.addFriend(id: id)
//        let user = try await NetworkManager.shared.getUser(id: id)
//        await MainActor.run {
//            friends.append(user)
//        }
//        return true
//    }
//    
//    func removeFriend(id: String) {
//        friends = friends.filter { $0.id != id }
//        Task {
//            do {
//                try await NetworkManager.shared.deleteFriend(id: id)
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
//    
//    func logout() {
//        AuthService.logout()
//        user = nil
//        friends = []
//        ArtModel().removeAllArt()
//        Utility.lastSelectedFriends = []
//        Utility.lastReceivedFetchDate = nil
//    }
//    
//    
//}
