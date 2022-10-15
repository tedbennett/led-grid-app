//
//  LoggedInView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/09/2022.
//

import SwiftUI
import AlertToast

struct LoggedInView: View {
    @StateObject var drawViewModel = DrawViewModel()
    @ObservedObject var navigationManager = NavigationManager.shared
    @Environment(\.scenePhase) var scenePhase
    @Binding var loggedIn: Bool
    
    @State private var selection = 0
    
    @State private var launched = false
    
    @StateObject var artViewModel = ArtViewModel()
    @StateObject var userViewModel = UserViewModel()
    @StateObject var friendsViewModel = FriendsViewModel()
    
    var body: some View {
        ZStack {
            AddFriendHandler()
            TabView(selection: $navigationManager.currentTab) {
                DrawView()
                    .tabItem {
                        Label("Draw", systemImage: "square.grid.2x2")
                    }.tag(0)
                    .environmentObject(drawViewModel)
                    .environmentObject(artViewModel)
                ArtView()
                    .tabItem {
                        Label("Art", systemImage: "tray")
                    }.environmentObject(artViewModel)
                    .environmentObject(drawViewModel)
                    .badge(artViewModel.badgeNumber)
                    .tag(1)
                SettingsView(loggedIn: $loggedIn)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }.tag(2)
                    .environmentObject(userViewModel)
            }
            .environmentObject(friendsViewModel)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active && loggedIn && launched {
                    Task {
                        await artViewModel.refreshReceivedArt()
                    }
                } else {
                    launched = true
                }
            }
            .onChange(of: loggedIn) {
                guard !$0 else { return }
                artViewModel.removeAllArt()
            }
        }
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView(loggedIn: .constant(true))
    }
}
