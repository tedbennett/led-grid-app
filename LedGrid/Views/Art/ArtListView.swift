//
//  ArtListView.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/10/2022.
//

import SwiftUI

struct ArtListView: View {
    @ObservedObject var viewModel = ArtListViewModel()
    @StateObject var reactionsViewModel = ArtReactionsViewModel()
    var user: User
    
    @FetchRequest var art: FetchedResults<PixelArt>
    
    init(user: User) {
        let request = PixelArt.fetchRequest()
        request.predicate = NSPredicate(format: "ANY users.id == %@", user.id)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(PixelArt.sentAt), ascending: false)]
        self._art = FetchRequest(fetchRequest: request)
        self.user = user
    }
    
    var body: some View {
        GeometryReader { listGeometry in
            ZStack {
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack {
                            ForEach(art) { art in
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
                                        .onTapGesture {
                                            art.opened.toggle()
                                        }
                                    
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
                    await PixeeProvider.fetchArt()
                }
                .environmentObject(viewModel)
                .environmentObject(reactionsViewModel)
                .navigationTitle(user.fullName ?? "Unknown")
                .blur(radius: viewModel.showUpgradeView ? 20 : 0)
            }
            SlideOverView(isOpened: $viewModel.showUpgradeView) {
                UpgradeView(isOpened: $viewModel.showUpgradeView)
            }
        }
    }
}

//struct ArtListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ArtListView(user: User.example, art: [PixelArt.example]).environmentObject(ArtViewModel())
//        }
//    }
//}
