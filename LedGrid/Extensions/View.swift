//
//  View.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/10/2022.
//

import SwiftUI

extension View {
    func editableText(editing: Binding<Bool>, _ didSelectEmoji: @escaping (String) -> Void) -> some View {
        modifier(EditableText(editing: editing, didSelectEmoji: didSelectEmoji))
    }
}


enum CenteredAlignment {
    case vertical
    case horizontal
    case both
}

struct Centered: ViewModifier {
    var alignment: CenteredAlignment

    func body(content: Content) -> some View {
        HStack {
            if alignment != .vertical {
                Spacer()
            }
            VStack {
                if alignment != .horizontal {
                    Spacer()
                }
                content
                if alignment != .horizontal {
                    Spacer()
                }
            }
            if alignment != .vertical {
                Spacer()
            }
        }
    }
}

extension View {
    func centered(_ alignment: CenteredAlignment = .both) -> some View {
        modifier(Centered(alignment: alignment))
    }
}
