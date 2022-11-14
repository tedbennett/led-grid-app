//
//  ArtAssociatedNamesView.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/11/2022.
//

import SwiftUI

struct ArtAssociatedNamesView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.lastUpdated, order: .reverse)]) var names: FetchedResults<ArtAssociatedName>
    
    func nameExists(_ name: String, artId: String) -> Bool {
        let name = name.lowercased().trimmingCharacters(in: .whitespaces)
        return names.contains(where: { (artId != $0.art?.id) && $0.name.lowercased().trimmingCharacters(in: .whitespaces) == name })
    }
    
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(names) { name in
                    if let art = name.art {
                        ArtAssociatedNameCard(name: name, art: art, nameExists: nameExists)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }
}

//struct NamedWidgetsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NamedWidgetsView()
//    }
//}
