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
            Text("PIXEE").font(.custom("SubwayTickerGrid", size: 40))
            Spacer()
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gear")
            }
            .buttonStyle(StdButton())
        }
    }
}

#Preview {
    HeaderView()
        .environment(UserManager(user: APIUser.example))
}
