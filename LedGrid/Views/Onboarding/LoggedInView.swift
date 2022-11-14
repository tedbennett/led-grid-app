//
//  LoggedInView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/09/2022.
//

import SwiftUI
import AlertToast
import WidgetKit

struct LoggedInView: View {
    @ObservedObject var navigationManager = NavigationManager.shared
    @Environment(\.scenePhase) var scenePhase
    @Binding var loggedIn: Bool
    @State private var showUpdateView = false
    
    @StateObject var userViewModel = UserViewModel()
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "opened = false")) var unopenedArt: FetchedResults<PixelArt>
    
    var body: some View {
        ZStack {
            AddFriendHandler()
            TabView(selection: $navigationManager.currentTab) {
                DrawView()
                    .tabItem {
                        Label("Draw", systemImage: "square.and.pencil")
                    }.tag(0)
                ArtView()
                    .tabItem {
                        Label("Art", systemImage: "square.grid.2x2")
                    }
                    .badge(unopenedArt.count)
                    .tag(1)
                SettingsView(loggedIn: $loggedIn)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }.tag(2)
                    .environmentObject(userViewModel)
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active && loggedIn {
                    WidgetCenter.shared.reloadAllTimelines()
                    Task {
                        await PixeeProvider.fetchArt()
                        await PixeeProvider.fetchReactions()
                    }
                } else if newPhase != .active {
                    PersistenceManager.shared.save()
                }
            }
            .onChange(of: loggedIn) {
                guard !$0 else { return }
                Task {
                    await PixeeProvider.removeAllArtAndUsers()
                }
            }
            .sheet(isPresented: $showUpdateView) {
                UpdateView {
                    showUpdateView = false
                }
            }
            .onAppear {
                showUpdateView = VersionManager.checkVersionNumber()
            }
        }
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView(loggedIn: .constant(true))
    }
}
