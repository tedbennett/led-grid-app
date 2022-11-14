//
//  EditableText.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/11/2022.
//

import SwiftUI


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
    }
}


extension View {
    func editableText(editing: Binding<Bool>, _ didSelectEmoji: @escaping (String) -> Void) -> some View {
        modifier(EditableText(editing: editing, didSelectEmoji: didSelectEmoji))
    }
}

