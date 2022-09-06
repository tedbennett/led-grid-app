//
//  StandardButton.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import SwiftUI

struct StandardButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(Color.gray.opacity(0.2).cornerRadius(15))
            .opacity(isEnabled && !configuration.isPressed ? 1 : 0.5)
    }
}
