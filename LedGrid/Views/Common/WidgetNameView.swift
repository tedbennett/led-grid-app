//
//  WidgetNameView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/10/2022.
//

import SwiftUI

struct WidgetNameView: View {
    var art: PixelArt
    @Binding var isOpened: Bool
    @State private var text: String
    @State private var invalidName: Bool = false
    @FetchRequest(sortDescriptors: []) var names: FetchedResults<ArtAssociatedName>
    
    init(art: PixelArt, isOpened: Binding<Bool>) {
        self.art = art
        self._text = State(wrappedValue: art.associatedName?.name ?? "")
        self._isOpened = isOpened
    }
    
    func nameExists(_ name: String) -> Bool {
        let name = name.lowercased().trimmingCharacters(in: .whitespaces)
        return names.contains(where: { (art.id != $0.art?.id) && $0.name.lowercased().trimmingCharacters(in: .whitespaces) == name })
    }
    
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                CloseButton {
                    withAnimation {
                        isOpened.toggle()
                    }
                }
            }
            VStack {
                TextField("Enter art name", text: $text)
                    .multilineTextAlignment(.center)
                    .font(.system(.title, design: .rounded).weight(.medium))
                    .onChange(of: text) { newText in
                        if newText.count > 20 {
                            text = String(newText.prefix(20))
                        } else {
                            invalidName = nameExists(newText)
                        }
                    }
                Divider()
                    .frame(height: 1)
                
                if !invalidName {
                    Text("To show this art in a widget, you need choose a memorable name for it.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Art with this name already exists\nPlease try another")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                }
            }
            
            Button {
                let id = art.objectID
                let imageData = Helpers.getImageData(for: art)
                Task {
                    try? await CoreDataService.setArtName(text, for: id, imageData: imageData)
                }
                withAnimation {
                    isOpened.toggle()
                }
            } label: {
                Text("Save")
            }.buttonStyle(LargeButton())
                .disabled(invalidName || text.isEmpty)
            Accordion(
                item: AccordionItem(
                    title: "How does this work?",
                    subtitle: nil,
                    image: "plus.square",
                    items: [
                        "Select a unique name, and press save",
                        "On your home screen, create a Pixee widget",
                        "Long press the widget to edit it",
                        "Select 'Name', and find your named art",
                        "You can see your named widgets in the settings tab"
                    ]
                )
            ).foregroundColor(.gray)
                .tint(.gray)
        }.padding(.horizontal, 0)
        
    }
}

//struct WidgetNameView_Previews: PreviewProvider {
//    init() { Utility.artNamesForWidget = [ArtAssociatedName(name: "Hi", artId: "1234")] }
//    static var previews: some View {
//        Utility.artNamesForWidget = [ArtAssociatedName(name: "Hi", artId: "1234")]
//        return WidgetNameView(artId: "123", isOpened: .constant(true))
//    }
//}

