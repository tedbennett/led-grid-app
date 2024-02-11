//
//  FriendsRoot.swift
//  LedGrid
//
//  Created by Ted Bennett on 11/02/2024.
//

import SwiftUI

struct FriendsRoot: View {
    var user: APIUser? {
        LocalStorage.user
    }

    var body: some View {
        if let user = user {
            FriendsView(user: user)
        } else {
            SignUpView()
        }
    }
}

#Preview {
    FriendsRoot()
}
