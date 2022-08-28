//
//  SlideOverView.swift
//  LedGrid
//
//  Created by Ted on 27/08/2022.
//

import SwiftUI

struct SlideOverView<Content>: View where Content: View {
    @Binding var isOpened: Bool
    let content: () -> Content
    init(
        isOpened: Binding<Bool>,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        _isOpened = isOpened
        self.content = content
    }
    var body: some View {
        if isOpened {
            content()
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
                .gesture(DragGesture().onChanged { val in
                    if val.translation.height > 50.0 {
                        withAnimation {
                            isOpened = false
                        }
                    }
                })
                .padding(10)
                .padding(.bottom, 20)
                .transition(AnyTransition.move(edge: .bottom))
                .zIndex(99)
            
        }
    }
}

struct SlideOverView_Previews: PreviewProvider {
    static var previews: some View {
        SlideOverView(isOpened: .constant(true), {})
    }
}
