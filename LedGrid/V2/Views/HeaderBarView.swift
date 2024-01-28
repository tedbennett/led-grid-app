//
//  HeaderBarView.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import SwiftUI

struct HeaderBarView: View {
    @Binding var tab: Tab

    var body: some View {
        VStack {
            Text("pixee").font(.custom("SubwayTickerGrid", size: 48))
            Picker("Selected Tab", selection: $tab) {
                Text("Drafts").tag(Tab.drafts)
                Text("Draw").tag(Tab.draw)
                Text("Art").tag(Tab.art)
            }.pickerStyle(.segmented)
                .id("Picker")
                .padding()
        }
    }
}

#Preview {
    HeaderBarView(tab: .constant(.draw))
}
