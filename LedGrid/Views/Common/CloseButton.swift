//
//  CloseButton.swift
//  LedGrid
//
//  Created by Ted on 27/08/2022.
//

import SwiftUI

struct CloseButton: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .padding(6)
                .background(Color.gray.opacity(0.2).cornerRadius(15))
        }
    }
}

//struct CloseButton_Previews: PreviewProvider {
//    static var previews: some View {
//        CloseButton()
//    }
//}
