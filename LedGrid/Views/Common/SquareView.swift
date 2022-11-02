//
//  SquareView.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI

struct SquareView: View {
    var color: Color
    var strokeWidth = 0.0
    var cornerRadius = 3.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(color)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(UIColor.gray), lineWidth: strokeWidth)

            )
            .aspectRatio(contentMode: .fit)
    }
}

struct SquareView_Previews: PreviewProvider {
    static var previews: some View {
        SquareView(color: .orange)
            .preferredColorScheme(.dark)
    }
}
