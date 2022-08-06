//
//  UserOrb.swift
//  LedGrid
//
//  Created by Ted on 01/08/2022.
//

import SwiftUI

struct UserOrb: View {
    var text: String?
    var isSelected: Bool
    
    var body: some View {
        GeometryReader{ g in
            ZStack {
                Circle()
                    .strokeBorder(isSelected ? Color.accentColor : Color.gray, lineWidth: isSelected ? 3 : 1)
                Text(text ?? "?")
                    .font(
                        .system(
                            size: g.size.height > g.size.width ? g.size.width * 0.4: g.size.height * 0.4,
                            design: .rounded
                        ).bold()
                    )
            }
        }
    }
}

//struct UserOrb_Previews: PreviewProvider {
//    static var previews: some View {
//        UserOrb()
//    }
//}
