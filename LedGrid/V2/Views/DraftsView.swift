
//
//  DraftsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/06/2023.
//

import SwiftData
import SwiftUI

struct DraftsView: View {
    let columns = [
        GridItem(.flexible(minimum: 80)),
        GridItem(.flexible(minimum: 80)),
    ]
    @Binding var selectedDraftId: String?
    
    @Query(sort: \DraftDrawing.updatedAt, order: .reverse, animation: .bouncy) var drafts: [DraftDrawing] = []
    
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
        }.sensoryFeedback(.success, trigger: feedback)
    }
}

struct DraftsViewPreview: PreviewProvider {
    static var selectedUUID = UUID().uuidString
    static var container = {
        let container = try! ModelContainer(for: DraftDrawing.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let selected = DraftDrawing()
        selected.id = selectedUUID
        container.mainContext.insert(selected)
        container.mainContext.insert(DraftDrawing())
        container.mainContext.insert(DraftDrawing())
        return container
    }()
    
    static var previews: some View {
        DrawingsView(selectedDraftId: .constant(selectedUUID)) {}
            .modelContainer(container)
    }
}
