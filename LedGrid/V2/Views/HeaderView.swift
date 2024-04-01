//
//  HeaderBarView.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        NavigationStack {
            HStack {
                Text("PIXEE").font(.custom("FiraMono Nerd Font", size: 40))
                Spacer()
                if let user = LocalStorage.user {
                    NavigationLink(destination: {
                        FriendsView(user: user)
                    }, label: {
                        Image(systemName: "person.2")
                    })
                    .buttonStyle(StdButton())
                    NavigationLink(destination: {
                        SettingsView(user: user)
                    }, label: {
                        Image(systemName: "gear")
                    })
                    .buttonStyle(StdButton())
                } else {
                    Button {
                        NotificationCenter.default.post(name: Notification.Name.showSignIn, object: true)
                    } label: {
                        Image(systemName: "person.2")
                    }
                    .buttonStyle(StdButton())
                    Button {
                        NotificationCenter.default.post(name: Notification.Name.showSignIn, object: nil)
                    } label: {
                        Image(systemName: "gear")
                    }
                    .buttonStyle(StdButton())
                }
            }
        }
    }
}

#Preview {
    HeaderView()
}
