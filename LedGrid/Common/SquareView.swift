//
//  SquareView.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI

struct SquareView: View {
    var color: Color
    var strokeWidth = 2.0
    var body: some View {
        Rectangle()
            .foregroundColor(color)
            .overlay(
                RoundedRectangle(cornerRadius: 1)
                    .stroke(Color(UIColor.gray), lineWidth: strokeWidth)
            )
    }
}

struct SquareView_Previews: PreviewProvider {
    static var previews: some View {
        SquareView(color: .orange)
            .preferredColorScheme(.dark)
    }
}
