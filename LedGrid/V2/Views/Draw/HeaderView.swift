//
//  HeaderBarView.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import SwiftUI

struct HeaderView: View {
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            HStack {
                Text("PIXEE").font(.custom("FiraMono Nerd Font", size: 40))
                Spacer()
                Button {
                    if LocalStorage.user == nil {
                        NotificationCenter.default.post(name: Notification.Name.showSignIn, object: true)
                    } else {
                        path.append("friends")
                    }
                } label: {
                    Image(systemName: "person.2")
                }
                .buttonStyle(StdButton())
                Button {
                    if LocalStorage.user == nil {
                        NotificationCenter.default.post(name: Notification.Name.showSignIn, object: nil)
                    } else {
                        path.append("settings")
                    }
                } label: {
                    Image(systemName: "gear")
                }
                .buttonStyle(StdButton())
            }.navigationDestination(for: String.self) { path in
                if path == "settings", let user = LocalStorage.user {
                    SettingsView(user: user)
                }
                if path == "friends", let user = LocalStorage.user {
                    FriendsView(user: user)
                }
            }.onReceive(NotificationCenter.default.publisher(for: .navigate), perform: { notif in
                if let destination = notif.object as? String {
                    path.append(destination)
                }
            })
        }
    }
}

#Preview {
    HeaderView()
}
