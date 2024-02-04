//
//  DrawingsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/06/2023.
//

import SwiftData
import SwiftUI

struct DrawingsView: View {
    @Binding var selectedDraftId: UUID?

    @Query(sort: \DraftArt.lastUpdated, order: .reverse, animation: .bouncy) var drafts: [DraftArt] = []

    @State private var feedback = false

    let scrollToDrawView: () -> Void

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Menu {
                    Button {} label: {
                        Text("Sent")
                    }
                    Button {} label: {
                        Text("Received")
                    }
                    Button {} label: {
                        Text("Drafts")
                    }
                } label: {
                    Text("DRAFTS").font(.custom("SubwayTickerGrid", size: 40))
                    Image(systemName: "chevron.down").font(.system(size: 18, weight: .heavy))
                }.buttonStyle(.plain)
                Spacer()
            }.padding(.top, 50).padding(.leading, 20)
            DrawingList(drawings: drafts) { id in
                selectedDraftId = id
                feedback.toggle()
                withAnimation {
                    scrollToDrawView()
                }
            }
        }
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
        DrawingsView(selectedDraftId: .constant(selectedUUID)) {}
            .modelContainer(container)
    }
}
