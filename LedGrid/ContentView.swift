//
//  ContentView.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI
import AlertToast
import WidgetKit

struct ContentView: View {
    @StateObject var viewModel = DrawViewModel()
    @ObservedObject var notificationManager = NotificationManager.shared
    @Environment(\.scenePhase) var scenePhase
    @State private var loggedIn = false
    
    @State private var addedFriend = false
    @State private var failedToAddFriend = false
    @State private var alreadyFriend = false
    
    @ObservedObject var gridManager =  GridManager.shared
    
    @State private var selection = 0
    
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
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .label
    }
    
    func parseUrl(_ url: URL) {
        dump(url)
        if url.scheme == "widget" && url.host == "received" {
            NotificationManager.shared.selectedTab = 1
            return
        }
        guard url.pathComponents.count == 3,
              url.pathComponents[1] == "user" else {
            return
        }
        let id = url.pathComponents[2]
        guard id != Utility.user?.id else {
            failedToAddFriend.toggle()
            return
        }
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
            TabView(selection: $notificationManager.selectedTab) {
                DrawView()
                    .tabItem {
                        Label("Draw", systemImage: "square.grid.2x2")
                    }.tag(0)
                ReceivedView()
                    .tabItem {
                        Label("Received", systemImage: "tray")
                    }.badge(gridManager.receivedGrids.filter({!$0.opened && !$0.hidden}).count)
                    .tag(1)
//                SentView().tabItem {
//                    Label("Sent", systemImage: "paperplane")
//                }.tag(2)
                SettingsView(loggedIn: $loggedIn).tabItem {
                    Label("Settings", systemImage: "gear")
                }.tag(2)
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

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static var shared = NotificationManager()
    
    private override init() { super.init() }
    
    @Published var selectedTab = 0
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Task {
            await GridManager.shared.handleReceivedNotification()
            WidgetCenter.shared.reloadAllTimelines()
        }
        completionHandler([[.banner, .badge, .sound]])
    }
    
    // User opened notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        await GridManager.shared.handleReceivedNotification()
        DispatchQueue.main.async {
            self.selectedTab = 1
        }
    }
}
