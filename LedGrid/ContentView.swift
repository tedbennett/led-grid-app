//
//  ContentView.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = DrawViewModel()
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        TabView {
            DrawView().tabItem {
                Label("Draw", systemImage: "pencil")
            }
            ReceivedView().tabItem {
                Label("Received", systemImage: "tray")
            }
            SentView().tabItem {
                Label("Sent", systemImage: "paperplane")
            }
            SettingsView().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
