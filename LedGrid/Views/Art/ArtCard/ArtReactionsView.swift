//
//  ArtReactionsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 05/10/2022.
//

import SwiftUI

struct ArtReactionsView: View {
    @EnvironmentObject var viewModel: ArtReactionsViewModel
    @ObservedObject var art: PixelArt
    var body: some View {
        Group {
            if art.sender == Utility.user?.id {
                HStack {
                    if let reaction = art.reaction(for: viewModel.userId) {
                        Text(reaction.reaction).font(.title)
                    } else {
                        Image(systemName: "hand.thumbsup.circle").font(.title2).opacity(0.5)
                    }
                }
                .padding(10)
                .background(Color(uiColor: .systemGray5))
                .cornerRadius(15)
            } else {
                HStack {
                    Spacer()
                    HStack(spacing: 15) {
                        if viewModel.openedReactionsId == art.id {
                            Image(systemName: "plus").font(.title2).editableText(editing: $viewModel.emojiPickerOpen) { emoji in
                                viewModel.sendReaction(emoji, for: art)
                            }
                            ForEach(viewModel.emojis, id: \.self) { emoji in
                                Button {
                                    if let id = Utility.user?.id, art.reaction(for: id)?.reaction != emoji {
                                        viewModel.sendReaction(emoji, for: art)
                                    } else {
                                        viewModel.closeReactions()
                                    }
                                } label: {
                                    Text(emoji).font(.title)
                                }
                            }
                            Button {
                                viewModel.closeReactions()
                            } label: {
                                Image(systemName: "xmark").font(.title3)
                            }.buttonStyle(.plain)
                        } else  {
                            Button {
                                viewModel.openReactions(for: art.id)
                            } label: {
                                if let id = Utility.user?.id, let reaction = art.reaction(for: id) {
                                    Text(reaction.reaction).font(.title)
                                } else {
                                    Image(systemName: "hand.thumbsup.circle").font(.title2)
                                }
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(10)
                    .background(Color(uiColor: .systemGray5))
                    .cornerRadius(15)
                    .disabled(art.sender == Utility.user?.id)
                }
            }
        }
    }
}

//struct ArtReactionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtReactionsView(artId: "1")
//            .environmentObject(ArtReactionsViewModel())
//    }
//}


protocol InvisibleTextViewDelegate: AnyObject {
    func valueChanged(emoji: String)
}

class InvisibleTextView: UIView, UIKeyInput {
    weak var delegate: InvisibleTextViewDelegate?

    override var canBecomeFirstResponder: Bool { true }

    // MARK: UIKeyInput
    
    var hasText: Bool { false }

    func insertText(_ text: String) {
        setNeedsDisplay()
        guard text.isSingleEmoji else { return }
        delegate?.valueChanged(emoji: text)
    }

    func deleteBackward() {
        
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
}

struct InvisibleTextViewWrapper: UIViewRepresentable {
    typealias UIViewType = InvisibleTextView
    var didSelectEmoji: (String) -> Void
    @Binding var isFirstResponder: Bool
    
    class Coordinator: InvisibleTextViewDelegate {
        var parent: InvisibleTextViewWrapper
        
        init(_ parent: InvisibleTextViewWrapper) {
            self.parent = parent
        }
        
        func valueChanged(emoji: String) {
            parent.didSelectEmoji(emoji)
            parent.isFirstResponder = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> InvisibleTextView {
        let view = InvisibleTextView()
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: InvisibleTextView, context: Context) {
        if isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        } else {
            DispatchQueue.main.async {
                uiView.resignFirstResponder()
            }
        }
    }
    
    
}

struct EditableText: ViewModifier {
    @Binding var editing: Bool
    var didSelectEmoji: (String) -> Void
    
    func body(content: Content) -> some View {
        content
            .background(InvisibleTextViewWrapper(didSelectEmoji: didSelectEmoji, isFirstResponder: $editing))
            .onTapGesture {
                if !editing { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                editing.toggle()
            }
//            .background(editing ? Color.gray : Color.clear)
    }
}

extension View {
    func editableText(editing: Binding<Bool>, _ didSelectEmoji: @escaping (String) -> Void) -> some View {
        modifier(EditableText(editing: editing, didSelectEmoji: didSelectEmoji))
    }
}

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

    var containsEmoji: Bool { contains { $0.isEmoji } }
}
