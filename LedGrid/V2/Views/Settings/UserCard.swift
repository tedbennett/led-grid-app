//
//  UserCard.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import SwiftUI

struct UserCard: View {
    var user: APIUser

    init(_ user: APIUser) {
        self.user = user
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(user.name ?? user.username).fontWeight(.medium)
                Text("@\(user.username)").font(.caption).foregroundStyle(.gray)
            }
            Spacer()
            Button {} label: {
                Image(systemName: "person.badge.plus")
            }
        }
        .tint(.primary)
    }
}

#Preview {
    List {
        UserCard(APIUser(createdAt: .now, email: "", id: UUID().uuidString, name: "Ridiculously long name that is so incredibly long", plus: false, username: "Really really long username"))
    }
}
