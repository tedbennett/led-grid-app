//
//  RecentColors.swift
//  LedGrid
//
//  Created by Ted Bennett on 11/02/2024.
//

import SwiftUI

struct RecentColors: View {
    var colors: [Color]
    var selectColor: (Color) -> Void
    var body: some View {
        HStack(spacing: 15) {
            ForEach(colors, id: \.self) { color in
                Button {
                    selectColor(color)
                } label: {
                    Circle()
                        .fill(color)
                        .stroke(.bar, lineWidth: 4)
                        .frame(width: 25, height: 25)
                }
            }
        }
    }
}

#Preview {
    RecentColors(colors: [Color.red, Color.blue]) { _ in
    }
}
