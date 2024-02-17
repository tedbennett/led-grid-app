//
//  Header.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/02/2024.
//

import SwiftUI

struct DrawingsHeader: View {
    @Binding var tab: DrawingsTab
    var body: some View {
        HStack(alignment: .center) {
            Menu {
                Button {
                    tab = .sent
                } label: {
                    Text("Sent")
                }
                Button {
                    tab = .received
                } label: {
                    Text("Received")
                }
                Button {
                    tab = .drafts
                } label: {
                    Text("Drafts")
                }
            } label: {
                Text(tab.rawValue.uppercased()).font(.custom("FiraMono Nerd Font", size: 40))
                Image(systemName: "chevron.down").font(.system(size: 18, weight: .heavy))
            }.buttonStyle(.plain)
            Spacer()
        }.padding(.top, 50).padding(.leading, 20)
    }
}

#Preview {
    DrawingsHeader(tab: .constant(.sent))
}
