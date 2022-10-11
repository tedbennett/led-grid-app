//
//  InitialsOrbView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/09/2022.
//

import SwiftUI

struct InitialsOrbView: View {
    var text: String?
    var isSelected: Bool = false
    
    var body: some View {
        GeometryReader{ g in
            ZStack {
                Circle()
                    .strokeBorder(isSelected ? Color.accentColor : Color.gray, lineWidth: isSelected ? 3 : 1)
                Text(text ?? "?")
                    .font(
                        .system(
                            size: min(g.size.height, g.size.width) * 0.4,
                            design: .rounded
                        ).bold()
                    )
            }
        }
    }
}

struct InitialsOrbView_Previews: PreviewProvider {
    static var previews: some View {
        InitialsOrbView()
    }
}
