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
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack {
                    ForEach(art.filter { !$0.hidden }) { art in
                        Section {
                            ArtCardView(art: art)
                                .id(art.id)
                                .padding()
                                .background( Color(uiColor: .systemGray6))
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
            Task {
                await artViewModel.refreshArt()
            }
        }
        .environmentObject(viewModel)
        .environmentObject(reactionsViewModel)
        .navigationTitle(viewModel.user.fullName ?? "Unknown")
        //        .onAppear {
        //            viewModel.fetchArt()
        //        }
    }
    
}

struct ArtListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ArtListView(user: User.example, art: [PixelArt.example]).environmentObject(ArtViewModel())
        }
    }
}
