//
//  ArtListView.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/10/2022.
//

import SwiftUI

struct ArtListView: View {
    @EnvironmentObject var artViewModel: ArtViewModel
    @ObservedObject var viewModel: ArtListViewModel
    @StateObject var reactionsViewModel = ArtReactionsViewModel()
    var art: [PixelArt]
    
    
    init(user: User, art: [PixelArt]) {
        viewModel = ArtListViewModel(user: user)
        self.art = art
        //        let predicate = {
        //            let sender = NSPredicate(format: "sender = %@", user.id)
        //            let receivers = NSPredicate(format: "ANY receivers = %@", [user.id])
        //            let compound = NSCompoundPredicate(orPredicateWithSubpredicates: [sender, receivers])
        //            return NSCompoundPredicate(andPredicateWithSubpredicates: [
        //                compound,
        //                NSPredicate(format: "hidden != true")
        //            ])
        //        }()
        //        let sortDescriptor = NSSortDescriptor(key: #keyPath(StoredPixelArt.sentAt), ascending: false)
        //        self._art = FetchRequest(entity: StoredPixelArt.entity(), sortDescriptors: [sortDescriptor], predicate: predicate)
    }
    
    var body: some View {
        GeometryReader { listGeometry in
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack {
                        ForEach(art.filter { !$0.hidden }) { art in
                            
                            Section {
                                ArtCardView(art: art)
                                    .id(art.id)
                                    .padding()
                                    .background(
                                        GeometryReader { geo in
                                            Color(uiColor: .systemGray6)
                                                .onChange(of: geo.frame(in: .global)) {
                                                    if $0.minY > listGeometry.frame(in: .global).minY && $0.maxY < listGeometry.frame(in: .global).maxY {
                                                        if viewModel.animatingId != art.id {
                                                            viewModel.setAnimatingArt(art.id)
                                                        }
                                                    }
                                                }
                                        })
                                    .cornerRadius(10)
                                    .padding(8)
                                
                            }
                        }
                    }
                    .onChange(of: NavigationManager.shared.selectedGrid) { selectedGrid in
                        guard let selectedGrid = selectedGrid else { return }
                        withAnimation {
                            proxy.scrollTo(selectedGrid, anchor: .center)
                        }
                    }
                    
                }
            }
            .refreshable {
                await artViewModel.refreshArt()
            }
            .environmentObject(viewModel)
            .environmentObject(reactionsViewModel)
            .navigationTitle(viewModel.user.fullName ?? "Unknown")
        }
    }
    
}

struct ArtListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ArtListView(user: User.example, art: [PixelArt.example]).environmentObject(ArtViewModel())
        }
    }
}
