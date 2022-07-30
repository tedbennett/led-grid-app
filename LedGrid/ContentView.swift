//
//  ContentView.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI
import AlertToast

struct ContentView: View {
    @StateObject var viewModel = DrawViewModel()
    @Environment(\.scenePhase) var scenePhase
    @State private var loggedIn = false
    
    @State private var addedFriend = false
    @State private var failedToAddFriend = false
    @State private var alreadyFriend = false
    
    func parseUrl(_ url: URL) {
        guard url.pathComponents.count == 3,
              url.pathComponents[1] == "user" else {
            return
        }
        let id = url.pathComponents[2]
        Task {
            do {
                let added = try await UserManager.shared.addFriend(id: id)
                await MainActor.run {
                    if added {
                        addedFriend.toggle()
                    } else {
                        alreadyFriend.toggle()
                    }
                }
            } catch {
                failedToAddFriend.toggle()
            }
        }
    }
    
    var body: some View {
        if loggedIn {
            TabView() {
                DrawView().tabItem {
                    Label("Draw", systemImage: "pencil")
                }
                ReceivedView().tabItem {
                    Label("Received", systemImage: "tray")
                }
                SentView().tabItem {
                    Label("Sent", systemImage: "paperplane")
                }
                SettingsView(loggedIn: $loggedIn).tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }.onOpenURL { parseUrl($0) }
                .toast(isPresenting: $addedFriend) {
                    AlertToast(type: .complete(.gray), title: "Added friend")
                }
                .toast(isPresenting: $alreadyFriend) {
                    AlertToast(type: .error(.gray), title: "Already fdded friend")
                }
                .toast(isPresenting: $failedToAddFriend) {
                    AlertToast(type: .error(.gray), title: "Failed to add friend")
                }
            
        } else {
            LoginView(loggedIn: $loggedIn)
                .onAppear {
                    if NetworkManager.shared.credentialManager.canRenew() && Utility.user?.id != nil {
                        loggedIn = true
                    } else {
                        NetworkManager.shared.logout()
                    }
                }
        }
        
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(selection: .constant(1))
//    }
//}
