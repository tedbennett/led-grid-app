//
//  ArtView.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/06/2023.
//

import SwiftData
import SwiftUI

struct ArtView: View {
    let columns = [
        GridItem(.flexible(minimum: 80)),
        GridItem(.flexible(minimum: 80)),
    ]
    @Binding var selectedDraftId: UUID?
    
    @Query(sort: \DraftArt.lastUpdated, order: .reverse, animation: .bouncy) var drafts: [DraftArt] = []
    
    @State private var feedback = false

    let changeTab: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(drafts) { art in
                    GridView(grid: art.grid).aspectRatio(contentMode: .fit)
                        .border(Color.white, width: selectedDraftId == art.id ? 3 : 0)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        .onTapGesture {
                            selectedDraftId = art.id
                            feedback.toggle()
                            changeTab()
                        }
                       
                }
            }
        } .sensoryFeedback(.success, trigger: feedback)
    }
}

struct ArtViewPreview: PreviewProvider {
    static var selectedUUID = UUID()
    static var container = {
        let container = try! ModelContainer(for: DraftArt.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let selected = DraftArt()
        selected.id = selectedUUID
        container.mainContext.insert(selected)
        container.mainContext.insert(DraftArt())
        container.mainContext.insert(DraftArt())
        return container
    }()
    
    static var previews: some View {
        ArtView(selectedDraftId: .constant(selectedUUID)) { }
            .modelContainer(container)
    }
}
