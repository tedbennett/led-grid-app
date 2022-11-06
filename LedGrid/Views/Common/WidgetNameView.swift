//
//  WidgetNameView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/10/2022.
//

import SwiftUI

struct WidgetNameView: View {
    var artId: String?
    @Binding var isOpened: Bool
    @State private var text = ""
    @State private var nameExists: Bool = false
    
    @State private var tutorialExpanded = false
    
    
    var body: some View {
        VStack {
            Text("Create Widget")
                .font(.system(.title, design: .rounded).weight(.medium))
            TextField("Enter art name", text: $text)
                .multilineTextAlignment(.center)
                .font(.system(.title2, design: .rounded).weight(.medium))
                .onChange(of: text) { newText in
                    if newText.count > 20 {
                        text = String(newText.prefix(20))
                    } else {
//                        withAnimation {
                            nameExists = Utility.artNamesForWidget.contains(where: { $0.artId != artId && $0.name.lowercased().trimmingCharacters(in: .whitespaces) == newText
                                .lowercased()
                                .trimmingCharacters(in: .whitespaces) })
//                        }
                    }
                }
            Divider()
             .frame(height: 1)
            
            if !nameExists {
                Text("To show this art in a widget, you need choose a memorable name for it.")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            } else {
                Text("Art with this name already exists")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
            }
//            Button {
//                withAnimation {
//                    tutorialExpanded.toggle()
//                }
//            } label: {
//                HStack {
//                    Text("How to create a widget with this art?")
//                    Image(systemName: tutorialExpanded ? "chevron.up" : "chevron.down")
//                }
//            }
            Accordion {
                Text("How to create a widget with this art?")
            } content: {
                VStack {
                    Text("To show this art in a widget you need to:")
                    Text("Select and save a name for it")
                    Text("Navigate to your home screen, and add the Pixee widget. You can find out how to do that here")
                }
            }
//            if tutorialExpanded {
//                VStack {
//                    Text("To show this art in a widget you need to:")
//                    Text("Select and save a name for it")
//                    Text("Navigate to your home screen, and add the Pixee widget. You can find out how to do that here")
//                }
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: tutorialExpanded ? .none : 0)
//                .clipped()
//                .animation(.easeOut, value: tutorialExpanded)
//                .transition(.move(edge: .top))
//            }
        }.padding(.horizontal, 40)
        
    }
}

struct WidgetNameView_Previews: PreviewProvider {
    init() { Utility.artNamesForWidget = [ArtAssociatedName(name: "Hi", artId: "1234")] }
    static var previews: some View {
        Utility.artNamesForWidget = [ArtAssociatedName(name: "Hi", artId: "1234")]
        return WidgetNameView(artId: "123", isOpened: .constant(true))
    }
}


struct ArtAssociatedName: Codable {
    var id: String = UUID().uuidString
    var name: String
    var artId: String
}


struct Accordion<Content: View>: View {
    @State var label: () -> Text
    @State var content: () -> Content
    
    @State private var collapsed: Bool = true
    
    var body: some View {
        VStack {
            Button(
                action: { withAnimation { self.collapsed.toggle() } },
                label: {
                    HStack {
                        self.label()
                        Spacer()
                        Image(systemName: self.collapsed ? "chevron.down" : "chevron.up")
                    }
                    .padding(.bottom, 1)
                    .background(Color.white.opacity(0.01))
                }
            )
            .buttonStyle(PlainButtonStyle())
            
            VStack {
                self.content()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
            .clipped()
//            .animation(.easeOut)
            .transition(.slide)
        }
    }
}
