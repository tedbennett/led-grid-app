//
//  ArtAssociatedNameCard.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/11/2022.
//

import SwiftUI

struct ArtAssociatedNameCard: View {
    var name: ArtAssociatedName
    var art: PixelArt
    var grids: [Grid]
    @State private var text: String
    @State private var invalidName = false
    
    var nameExists: (String, String) -> Bool

    init(name: ArtAssociatedName, art: PixelArt, nameExists: @escaping (String, String) -> Bool) {
        self.name = name
        self.grids = art.art.toColors()
        self.art = art
        self.text = name.name
        self.nameExists = nameExists
    }
    
    

    var body: some View {
        VStack(spacing: 10) {

            GridView(grid: grids[0])
                .drawingGroup()

            VStack {
                TextField("Enter art name", text: $text)
                    .multilineTextAlignment(.center)
                    .font(.system(.title, design: .rounded).weight(.medium))
                    .onChange(of: text) { newText in
                        if newText.count > 20 {
                            text = String(newText.prefix(20))
                        } else {
                            invalidName = nameExists(text, art.id)
                        }
                    }
                Divider()
                    .frame(height: 1)
            }
            
            HStack {
                Button {
                    let id = art.objectID
                    let imageData = Helpers.getImageData(for: art)
                    Task {
                        try? await CoreDataService.setArtName(text, for: id, imageData: imageData)
                    }
                } label: {
                    Text("Save")
                }.disabled(text == name.name || invalidName)
                    .buttonStyle(StandardButton())
                
                Button {
                    let id = art.objectID
                    Task {
                        try? await CoreDataService.removeArtName(id: id)
                    }
                } label: {
                    Text("Delete")
                        .foregroundColor(.red)
                }.disabled(text == name.name || invalidName)
                    .buttonStyle(StandardButton())
                
            }

        }.padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(10)
        .padding(8)
        
    }
}

//struct NamedArtCard_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtAssociatedNameCard()
//    }
//}
