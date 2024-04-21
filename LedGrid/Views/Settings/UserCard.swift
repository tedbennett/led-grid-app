//
//  UserCard.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import SwiftUI

struct UserCard<Content: View>: View {
    var name: String?
    var username: String
    @ViewBuilder var content: () -> Content

    var usernameTag: String {
        "@\(username)"
    }
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name ?? usernameTag).fontWeight(.medium)
                if name != nil {
                    Text(usernameTag).font(.caption).foregroundStyle(.gray)
                }
            }
            Spacer()
            content()
        }
        .tint(.primary)
    }
}

#Preview {
    List {
        UserCard(name: "Ridiculously long name that is so incredibly long", username: "Really really long username") {}
    }
}
