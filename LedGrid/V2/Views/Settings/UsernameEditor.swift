//
//  UsernameEditor.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import SwiftUI

private enum UsernameStatus {
    case available
    case notAvailable
    case loading
    case notChanged
}

struct UsernameEditor: View {
    var username: String
    @State private var usernameField: String = ""
    @State private var status: UsernameStatus = .notChanged

    var statusImage: some View {
        Group {
            switch status {
            case .available:
                Image(systemName: "checkmark")
            case .notAvailable:
                Image(systemName: "xmark")
            case .loading:
                ProgressView()
            case .notChanged:
                EmptyView()
            }
        }
    }

    var body: some View {
        HStack {
            TextField("Username", text: $usernameField)
            statusImage
        }
        .onAppear {
            usernameField = username
            status = .notChanged
        }
    }
}

#Preview {
    UsernameEditor(username: "Username")
}
