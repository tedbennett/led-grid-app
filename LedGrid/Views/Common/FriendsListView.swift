//
//  FriendsListView.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import SwiftUI


struct FriendsView: View {
    @Binding var selectedFriends: [String]
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if friendsViewModel.friends.isEmpty {
                        Button {
                            Helpers.presentShareSheet()
                        } label: {
                            Text("Add some friends in settings to send art").font(.caption).foregroundColor(.gray)
                        }
                    } else {
                        ForEach(friendsViewModel.friends) { user in
                            VStack {
                                Button {
                                    if selectedFriends.contains(where: { user.id == $0 }) {
                                        selectedFriends = selectedFriends.filter { user.id != $0 }
                                    } else {
                                        selectedFriends.append(user.id)
                                    }
                                    
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                } label: {
                                    UserOrb(user: user, isSelected: selectedFriends.contains(where: { user.id == $0 }))
                                }.buttonStyle(.plain)
                                Text(user.fullName ?? "Unknown")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(width: 100)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.center)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }
                .frame(minWidth: geometry.size.width)      // Make the scroll view full-width
                .frame(height: geometry.size.height)
            }
        }
    }
}

