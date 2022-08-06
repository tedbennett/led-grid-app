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
    
    @ObservedObject var gridManager =  GridManager.shared
    
    init() {
        let systemFont = UIFont.systemFont(ofSize: 36, weight: .bold)
        var font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: 36)
        } else {
            font = systemFont
        }
        let strokeTextAttributes = [
          NSAttributedString.Key.strokeColor : UIColor.label,
          NSAttributedString.Key.foregroundColor : UIColor.systemBackground,
          NSAttributedString.Key.font : font,
          NSAttributedString.Key.strokeWidth : 4]
          as [NSAttributedString.Key : Any]

        UINavigationBar.appearance().largeTitleTextAttributes = strokeTextAttributes
    }
    
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
                }.badge(gridManager.receivedGrids.filter({!$0.opened}).count)
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
                        UserManager.shared.requestNotificationPermissions()
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
