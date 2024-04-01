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
    @Environment(\.modelContext) private var modelContext

    var canUndo: Bool
    var canRedo: Bool
    var undo: () -> Void
    var redo: () -> Void
    var send: ([String]) async -> Void

    func createNewDraft(size: GridSize) {
        modelContext.insert(DraftDrawing(size: size))
    }

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
                Menu {
                    Section("Create New Draft") {
                        Button("8 x 8") {
                            createNewDraft(size: .small)
                            feedback.toggle()
                        }
                        Button("10 x 10") {
                            createNewDraft(size: .medium)
                            feedback.toggle()
                        }
                        Button("12 x 12") {
                            createNewDraft(size: .large)
                            feedback.toggle()
                        }
                    }
                } label: {
                    Image(systemName: "plus.square").font(.title3)
                }
                .buttonStyle(StdButton())
                Button {
                    UIColorWellHelper.helper.execute?()
                    feedback.toggle()
                } label: {
                    Circle()
                        .fill(color)
                        .stroke(.bar, lineWidth: 4)
                        .frame(width: 36)
                        .background(
                            ColorPicker("", selection: $color, supportsOpacity: false)
                                .labelsHidden().opacity(0)
                        )
                }
            }
            HStack {
                Spacer()
                    .allowsHitTesting(false)
                SendArt { friends in
                    await send(friends)
                }
                Spacer()
            }
        }.padding()
            .sensoryFeedback(.impact(flexibility: .solid), trigger: feedback)
    }
}

#Preview {
    BottomBarView(color: .constant(.green), canUndo: true, canRedo: true, undo: {}, redo: {}, send: { _ in })
}

struct StdButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .foregroundStyle(.primary.opacity((configuration.isPressed || !isEnabled) ? 0.5 : 1))
            .background(
                Circle().fill(.bar.opacity(isEnabled ? 1 : 0.7))
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
