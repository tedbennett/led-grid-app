//
//  SettingsRoot.swift
//  LedGrid
//
//  Created by Ted Bennett on 11/02/2024.
//

import SwiftUI

struct SettingsRoot: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var user: APIUser? {
        LocalStorage.user
    }

    var body: some View {
        if let user = user {
            SettingsView(user: user) {
                presentationMode.wrappedValue.dismiss()
            }
        } else {
            SignIn {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    SettingsRoot()
}
