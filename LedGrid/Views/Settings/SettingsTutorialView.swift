//
//  SettingsTutorialView.swift
//  LedGrid
//
//  Created by Ted Bennett on 14/11/2022.
//

import SwiftUI

struct SettingsTutorialView: View {
    var dismiss: () -> Void
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Capsule().foregroundColor(.gray).frame(width: 40, height: 5).padding(.top, 10)
                    Spacer()
                }
                HStack {
                    Spacer()
                    
                    CloseButton {
                        dismiss()
                    }
                }.padding(.top, 15)
            }
            DrawTutorialView {
                dismiss()
            }
        }
    }
}

struct SettingsTutorialView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTutorialView { }
    }
}
