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
        Picker("Selected Tab", selection: $tab) {
            Text("Draw").tag(Tab.draw)
            Text("Art").tag(Tab.art)
        }.pickerStyle(.segmented)
            .id("Picker")
            .padding()
    }
}

#Preview {
    HeaderBarView(tab: .constant(.draw))
}
