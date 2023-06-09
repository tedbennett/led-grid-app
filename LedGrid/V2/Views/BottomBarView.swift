//
//  BottomBarView.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import SwiftUI

struct BottomBarView: View {
    var body: some View {
        HStack(alignment: .bottom) {
            Button {} label: {
                Image(systemName: "arrow.counterclockwise")
            }.padding(.leading, 10)
            Button {} label: {
                Image(systemName: "arrow.clockwise")
            }
            Spacer()
            Button {} label: {
                Image(systemName: "paperplane").padding().background(Circle().fill(.gray))
            }
            Spacer()
            Circle().fill().frame(width: 35).padding(.trailing, 10)
        }
    }
}

#Preview {
    BottomBarView()
}
