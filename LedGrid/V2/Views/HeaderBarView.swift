//
//  HeaderBarView.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import SwiftUI

struct HeaderBarView: View {
    @Binding var tab: Int

    var body: some View {
        Picker("Selected Tab", selection: $tab) {
            Text("Draw").tag(0)
            Text("Art").tag(1)
        }.pickerStyle(.segmented)
            .id("Picker")
            .padding()
    }
}

#Preview {
    HeaderBarView(tab: .constant(0))
}
