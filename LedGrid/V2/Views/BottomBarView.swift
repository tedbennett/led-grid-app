//
//  BottomBarView.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import SwiftUI

struct BottomBarView: View {
    @Binding var color: Color
    @State private var feedback = false

    var canUndo: Bool
    var canRedo: Bool
    var undo: () -> Void
    var redo: () -> Void
    var send: () -> Void

    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 10) {
                Button {
                    undo()
                    feedback.toggle()
                } label: {
                    Image(systemName: "arrow.counterclockwise").font(.title3)
                }
                .buttonStyle(StdButton())
                .disabled(!canUndo)

                Button {
                    redo()
                    feedback.toggle()
                } label: {
                    Image(systemName: "arrow.clockwise").font(.title3)
                }
                .buttonStyle(StdButton())
                .disabled(!canRedo)
                Spacer()

                Button {
                    logger.info("Pressed grid")
                    feedback.toggle()
                } label: {
                    Image(systemName: "grid").font(.title3)
                }
                .buttonStyle(StdButton())

                Button {
                    UIColorWellHelper.helper.execute?()
                    feedback.toggle()
                } label: {
                    Circle().fill(color).frame(width: 40)
                        .background(
                            ColorPicker("", selection: $color, supportsOpacity: false)
                                .labelsHidden().opacity(0)
                        )
                }
            }
            HStack {
                Spacer()
                    .allowsHitTesting(false)
                Button {
                    send()
                    feedback.toggle()
                } label: {
                    Image(systemName: "paperplane").font(.title).padding(5)
                }.buttonStyle(StdButton())
                Spacer()
            }
        }.padding()
            .sensoryFeedback(.impact(flexibility: .solid), trigger: feedback)
    }
}

#Preview {
    BottomBarView(color: .constant(.green), canUndo: true, canRedo: true, undo: {}, redo: {}, send: {})
}

struct StdButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .foregroundStyle(.background.opacity(configuration.isPressed ? 0.5 : 1))
            .background(
                Circle().fill(.primary.opacity(isEnabled ? 1 : 0.7))
            ).scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

extension UIColorWell {
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let uiButton = subviews.first?.subviews.last as? UIButton {
            UIColorWellHelper.helper.execute = {
                uiButton.sendActions(for: .touchUpInside)
            }
        }
    }
}

class UIColorWellHelper: NSObject {
    static let helper = UIColorWellHelper()
    var execute: (() -> Void)?
    @objc func handler(_ sender: Any) {
        execute?()
    }
}
