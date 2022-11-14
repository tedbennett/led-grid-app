//
//  PixeeLogoView.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/11/2022.
//

import SwiftUI

struct PixeeLogoView: View {
    var size: CGFloat = 48
    
    var body: some View {
        Image(systemName: "square.grid.2x2")
            .font(.system(size: size, weight: .regular))
            .rotationEffect(.degrees(45))
    }
}

struct PixeeLogoView_Previews: PreviewProvider {
    static var previews: some View {
        PixeeLogoView()
    }
}
