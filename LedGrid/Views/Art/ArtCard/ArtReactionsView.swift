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
        HStack {
            Spacer()
            HStack(spacing: 15) {
                if viewModel.openedReactionsId == art.id {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus").font(.title2)
                    }.buttonStyle(.plain)
                    ForEach(viewModel.emojis, id: \.self) { emoji in
                        Button {
                            viewModel.sendReaction(emoji)
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
                        Image(systemName: "hand.thumbsup.circle").font(.title2)
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

//struct ArtReactionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtReactionsView(artId: "1")
//            .environmentObject(ArtReactionsViewModel())
//    }
//}


class UIEmojiTextField: UITextField {
    
    var isEmoji = false {
        didSet {
            setEmoji()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setEmoji() {
        self.reloadInputViews()
    }
    
    override var textInputContextIdentifier: String? {
        return ""
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                self.keyboardType = .default
                return mode
            }
        }
        return nil
    }
    
}

struct EmojiInputField: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let button = UIView()
//        button.setImage(UIImage(systemName: "plus"), for: .normal)
//        button.setTitle("Hi", for: .normal)
        let input = KeyInputView()
        input.inputView = button
        input.becomeFirstResponder()
//        button.addAction(UIAction(handler: {_ in button.becomeFirstResponder()}), for: .touchDown)
//        emojiTextField.placeholder = placeholder
//        emojiTextField.text = text
//        emojiTextField.delegate = context.coordinator
//        button.addAction(, for: .touchDown)
        return button
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
//        uiView.text = text
    }
    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//
//    class Coordinator: NSObject {
//        var parent: EmojiInputField
//
//        init(parent: EmojiInputField) {
//            self.parent = parent
//        }
//
//    }
}

//struct EmojiContentView: View {
//
//    @State private var text: String = ""
//    @State private var isEmoji: Bool = false
//
//    var body: some View {
//
//        HStack{
//            EmojiTextField(text: $text, placeholder: "Enter emoji", isEmoji: $isEmoji)
//            Button("EMOJI") {
//                isEmoji.toggle()
//            }.background(Color.yellow)
//        }
//    }
//}

class KeyInputView: UIView {
   var _inputView: UIView?

   override var canBecomeFirstResponder: Bool { return true }
   override var canResignFirstResponder: Bool { return true }

   override var inputView: UIView? {
       set { _inputView = newValue }
       get { return _inputView }
   }
}

// MARK: - UIKeyInput
//Modify if need more functionality
extension KeyInputView: UIKeyInput {
    var hasText: Bool { return false }
    func insertText(_ text: String) {
        print(text)
    }
    func deleteBackward() {}
    
    
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
//                self.keyboardType = .default
                return mode
            }
        }
        return nil
    }
}
