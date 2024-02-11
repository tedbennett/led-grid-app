//
//  HeaderBarView.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("PIXEE").monospaced() // .font(.custom("SubwayTickerGrid", size: 40))
            Spacer()
            NavigationLink {
                FriendsRoot()
            } label: {
                Image(systemName: "person.2")
            }
            .buttonStyle(StdButton())
            NavigationLink {
                SettingsRoot()
            } label: {
                Image(systemName: "gear")
            }
            .buttonStyle(StdButton())
        }
    }
}

#Preview {
    HeaderView()
}
