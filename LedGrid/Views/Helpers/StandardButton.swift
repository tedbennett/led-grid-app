//
//  StandardButton.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import SwiftUI

struct StandardButton: ButtonStyle {
    var disabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.accentColor.opacity(disabled ? 0.5 : 1))
        //            .background(Color.gray.opacity(0.2))
        //            .overlay(
        //                RoundedRectangle(cornerRadius: 15)
        //                    .stroke(Color.accentColor.opacity(disabled ? 0.5 : 1), lineWidth: 2)
        //            )
            .padding(.vertical, 0)
            .disabled(disabled)
    }
}
