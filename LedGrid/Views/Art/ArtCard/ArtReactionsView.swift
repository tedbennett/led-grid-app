//
//  ArtReactionsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 05/10/2022.
//

import SwiftUI

struct ArtReactionsView: View {
    @EnvironmentObject var viewModel: ArtReactionsViewModel
    @ObservedObject var art: PixelArt
    var body: some View {
        Group {
            if art.sender == Utility.user?.id {
                HStack {
                    if let reaction = art.reaction(for: viewModel.userId) {
                        Text(reaction.reaction).font(.title)
                    } else {
                        Image(systemName: "hand.thumbsup.circle").font(.title2).opacity(0.5)
                    }
                }
                .padding(10)
                .background(Color(uiColor: .systemGray5))
                .cornerRadius(15)
            } else {
                HStack {
                    Spacer()
                    HStack(spacing: 15) {
                        if viewModel.openedReactionsId == art.id {
                            Image(systemName: "plus").font(.title2).editableText(editing: $viewModel.emojiPickerOpen) { emoji in
                                viewModel.sendReaction(emoji, for: art)
                            }
                            ForEach(viewModel.emojis, id: \.self) { emoji in
                                Button {
                                    if let id = Utility.user?.id, art.reaction(for: id)?.reaction != emoji {
                                        viewModel.sendReaction(emoji, for: art)
                                    } else {
                                        viewModel.closeReactions()
                                    }
                                } label: {
                                    Text(emoji).font(.title)
                                }
                            }
                            Button {
                                viewModel.closeReactions()
                            } label: {
                                Image(systemName: "xmark").font(.title3)
                            }.buttonStyle(.plain)
                        } else  {
                            Button {
                                viewModel.openReactions(for: art.id)
                            } label: {
                                if let id = Utility.user?.id, let reaction = art.reaction(for: id) {
                                    Text(reaction.reaction).font(.title)
                                } else {
                                    Image(systemName: "hand.thumbsup.circle").font(.title2)
                                }
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(10)
                    .background(Color(uiColor: .systemGray5))
                    .cornerRadius(15)
                    .disabled(art.sender == Utility.user?.id)
                }
            }
        }
    }
}

//struct ArtReactionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtReactionsView(artId: "1")
//            .environmentObject(ArtReactionsViewModel())
//    }
//}

