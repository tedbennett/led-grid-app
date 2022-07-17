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
    @Binding var selection: Int
    @State private var unopenedGrids: Int =  Utility.receivedGrids.reduce(0, { a, b in !b.opened ? a + 1 : a })
    
    var body: some View {
        TabView(selection: $selection) {
            DrawView().tabItem {
                Label("Draw", systemImage: "pencil")
            }
            ReceivedView(unopenedGrids: $unopenedGrids).tabItem {
                Label("Received", systemImage: "tray")
            }.badge(unopenedGrids)
            SentView().tabItem {
                Label("Sent", systemImage: "paperplane")
            }
            SettingsView().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(selection: .constant(1))
//    }
//}
