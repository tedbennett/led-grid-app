//
//  ArtListView.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/10/2022.
//

import SwiftUI
import AlertToast

struct ArtListView: View {
    @ObservedObject var viewModel = ArtListViewModel()
    @StateObject var reactionsViewModel: ArtReactionsViewModel
    var user: User
    
    @FetchRequest var art: FetchedResults<PixelArt>
    
    init(user: User) {
        let request = PixelArt.fetchRequest()
        request.predicate = NSPredicate(format: "ANY users.id == %@", user.id)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(PixelArt.sentAt), ascending: false)]
        self._art = FetchRequest(fetchRequest: request)
        self.user = user
        self._reactionsViewModel = StateObject(wrappedValue: ArtReactionsViewModel(userId: user.id))
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
                                                                reactionsViewModel.emojiPickerOpen = false
                                                            }
                                                            if reactionsViewModel.openedReactionsId != nil && art.id != reactionsViewModel.openedReactionsId {
                                                                reactionsViewModel.closeReactions()
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
                                NavigationManager.shared.selectedGrid = nil
                            }
                        }
                        
                    }
                }
                .refreshable {
                    await PixeeProvider.fetchArt()
                    await PixeeProvider.fetchReactions()
                }
                .environmentObject(viewModel)
                .environmentObject(reactionsViewModel)
                .navigationTitle(user.fullName ?? "Unknown")
                .blur(radius: (viewModel.showUpgradeView || viewModel.widgetArt != nil) ? 20 : 0)
                .allowsHitTesting(!viewModel.showUpgradeView && viewModel.widgetArt == nil)
            }
            SlideOverView(isOpened: $viewModel.showUpgradeView) {
                UpgradeView(isOpened: $viewModel.showUpgradeView)
            }
            SlideOverView(isOpened: $viewModel.widgetArt.mappedToBool()) {
                WidgetNameView(art: viewModel.widgetArt!, isOpened: $viewModel.widgetArt.mappedToBool())
            }
        }.simultaneousGesture(TapGesture()
            .onEnded { _ in
                reactionsViewModel.emojiPickerOpen = false
            }
        )
        .toast(isPresenting: $reactionsViewModel.didSendGrid) {
            AlertToast(type: .complete(.gray), title: "Sent Reaction")
        }
        .toast(isPresenting: $reactionsViewModel.failedToSendGrid) {
            AlertToast(type: .error(.gray), title: "Failed to send reaction")
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
