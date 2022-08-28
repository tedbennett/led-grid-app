//
//  LargeButton.swift
//  LedGrid
//
//  Created by Ted on 27/08/2022.
//

import SwiftUI

struct LargeButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    var isLoading: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            if isLoading {
                Spinner()
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(uiColor: .systemBackground))
            } else {
                configuration.label
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(uiColor: .systemBackground))
            }
            Spacer()
        }.padding()
            .background(Color(uiColor: .label))
            .cornerRadius(10)
            .opacity(isEnabled && !configuration.isPressed ? 1 : 0.5)
        
    }
}
