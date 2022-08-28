//
//  WidgetTutorialView.swift
//  LedGrid
//
//  Created by Ted on 16/08/2022.
//

import SwiftUI
let gridColors = [
    [Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground)],
    [Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .label), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .label), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground)],
    [Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .label), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .label), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground)],
    [Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground)],
    [Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground)],
    [Color(uiColor: .systemBackground), Color(uiColor: .label), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .label), Color(uiColor: .systemBackground)],
    [Color(uiColor: .systemBackground), Color(uiColor: .label), Color(uiColor: .label), Color(uiColor: .label), Color(uiColor: .label), Color(uiColor: .label), Color(uiColor: .label), Color(uiColor: .systemBackground)],
    [Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground), Color(uiColor: .systemBackground)]
]
struct WidgetTutorialView: View {
    @Binding var presented: Bool
    var body: some View {
        VStack() {
            ZStack {
                HStack {
                    Spacer()
                    Capsule().foregroundColor(.gray).frame(width: 40, height: 5).padding(.top, 10)
                    Spacer()
                }
                HStack {
                    Spacer()
                    
                    CloseButton {
                        presented = false
                        
                    }
                }.padding(.top, 15)
            }
            Title("Widgets", size: 40).frame(width: 100, height: 40)
                .padding(.top, 50)
                .padding(.bottom, 10)
            VStack() {
                Text("Pixee widgets let you see your last received pixel art, right on your home screen.").foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                MiniGridView(grid: gridColors, viewSize: .custom(stroke: 0, cornerRadius: 3, spacing: 3)).frame(width: 150, height: 150).padding(10).overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(uiColor: .label), lineWidth: 2)
                ).padding(.bottom, 30)
                
                Label {Text("How to add a widget") } icon: {
                    Image(systemName: "info.circle")
                }
                
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
                VStack(alignment: .leading, spacing: 25) {
                    HStack(alignment: .center, spacing: 10) {
                        Text("1.")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Text("Hold down any app on your home screen and select 'Edit Home Screen'")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    HStack(alignment: .center, spacing: 10) {
                        Text("2.").font(.system(size: 18, weight: .semibold, design: .rounded))
                        Text("Press the '+' button in the top-left corner")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    HStack(alignment: .center, spacing: 10) {
                        Text("3.").font(.system(size: 18, weight: .semibold, design: .rounded))
                        Text("Search for pixee, select which size widget you'd like and add it to your home screen.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                }
                .padding(.bottom, 10)
                Text("You can edit the widget by long-pressing it and selecting 'Edit Widget'").foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }.font(.system(size: 16, weight: .semibold, design: .rounded))
        }.padding(.horizontal, 20)
        
    }
}

struct WidgetTutorial_Previews: PreviewProvider {
    static var previews: some View {
        WidgetTutorialView(presented: .constant(true))
            .previewDevice("iPhone 13 mini")
    }
}

struct Title: UIViewRepresentable {
    
    let string: String
    let size: Double
    let alignment: NSTextAlignment
    
    init(_ string: String, size: Double = 36, alignment: NSTextAlignment = .center) {
        self.string = string
        self.size = size
        self.alignment = alignment
    }
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        label.textAlignment = alignment
        
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        let systemFont = UIFont.systemFont(ofSize: size, weight: .bold)
        var font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        let attributes = [
            NSAttributedString.Key.strokeColor : UIColor.label,
            NSAttributedString.Key.foregroundColor : UIColor.systemBackground,
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.strokeWidth : 4]
        as [NSAttributedString.Key : Any]
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        uiView.attributedText = attributedString
    }
}
