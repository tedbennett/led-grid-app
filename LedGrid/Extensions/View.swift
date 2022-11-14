//
//  View.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/10/2022.
//

import SwiftUI

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

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self.frame(width: 80, height: 80).edgesIgnoringSafeArea(.all))
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 0.8
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
