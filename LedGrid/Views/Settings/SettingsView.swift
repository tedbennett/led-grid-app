//
//  SettingsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var loggedIn: Bool
    @State private var showEditView = false
    @State private var showEmailModal = false
    @State private var showWidgetModal = false
    @State private var showUpgradeView = false
    @State private var showDeleteAccountAlert = false
    
    @FetchRequest(sortDescriptors: []) var friends: FetchedResults<User>
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section {
                        if friends.isEmpty {
                            Button {
                                Helpers.presentShareSheet()
                            } label: {
                                Text("Add friends to get started!")
                            }
                        }
                        ForEach(friends) { friend in
                            Text(friend.fullName ?? "Unknown Friend")
                                .swipeActions(allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await PixeeProvider.removeFriend(friend.id)
                                        }
                                    } label: {
                                        Label("Remove", systemImage: "trash.fill")
                                    }
                                }
                        }
                    } header: {
                        HStack {
                            Text("Friends")
                            Spacer()
                            Button {
                                Helpers.presentShareSheet()
                            } label: {
                                Image(systemName: "person.badge.plus")
                                    .font(.title3)
                            }
                        }
                    }
                    
                    Section {
                        Text(userViewModel.user?.fullName ?? "Unknown name")
                    } header: {
                        HStack {
                            Text("Name")
                            Spacer()
                            NavigationLink(isActive: $showEditView) {
                                EditNameView(isPresented: $showEditView)
                            } label: {
                                Text("Edit")
                            }
                        }
                    }
                    Section("Email") {
                        Text(userViewModel.user?.email ?? "Unknown email").foregroundColor(.gray)
                    }
                    
                    
                    Section {
                        Button {
                            withAnimation {
                                showUpgradeView = true
                            }
                        } label: {
                            Label {
                                Text(Utility.isPlus ? "Pixee Plus" : "Upgrade to Pixee Plus")
                            } icon: {
                                Image(systemName: "star")
                            }
                        }
                        Button {
                            showWidgetModal = true
                        } label: {
                            Label {
                                Text("How to add a widget")
                            } icon: {
                                Image(systemName: "plus.square.on.square")
                            }
                        }
                    
                        Button {
                            showEmailModal = true
                        } label: {
                            Label {
                                Text("Send Feedback")
                            } icon: {
                                Image(systemName: "envelope")
                            }
                        }
                    }
                }
                .refreshable {
                    await PixeeProvider.fetchFriends()
                }
                
                .blur(radius: showUpgradeView ? 20 : 0)
                .allowsHitTesting(!showUpgradeView)
                .navigationBarHidden(showUpgradeView)
                .listStyle(InsetGroupedListStyle())
                
                SlideOverView(isOpened: $showUpgradeView) {
                    UpgradeView(isOpened: $showUpgradeView)
                }
            }.navigationTitle("Settings").toolbar {
                
                Menu {
                    Button {
                        loggedIn = false
                        userViewModel.logout()
                    } label: {
                        Text("Logout")
                    }
                    
                    Button(role: .destructive) {
                        showDeleteAccountAlert = true
                    } label: {
                        Text("Delete Account")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(.title3, design: .rounded))
                        .padding(5)
                        .padding(.horizontal, 6)
                }
            }
            .sheet(isPresented: $showEmailModal) {
                MailView(recipient: "ted_bennett@icloud.com", subject: "Pixee Feedback", body: "Please enter your feedback below:\n\n\n\n\nThank you for leaving feedback and helping to improve Pixee!\n\nTed")
            }
            .sheet(isPresented: $showWidgetModal) {
                WidgetTutorialView(presented: $showWidgetModal).tint(Color(uiColor: .label))
            }
            .alert("Delete account?", isPresented: $showDeleteAccountAlert) {
                Button("Delete", role: .destructive) {
                    loggedIn = false
                    userViewModel.deleteAccount()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(loggedIn: .constant(true))
            .environmentObject(UserViewModel())
    }
}

struct EditNameView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var isPresented: Bool
    @State private var fullName = ""
    var body: some View {
        Form {
            Section("Full Name") {
                TextField("Full Name", text: $fullName)
            }
            Button {
                Task {
                    await userViewModel.updateUser(fullName: fullName)
                }
                isPresented = false
            } label: {
                Text("Save")
            }
        }.navigationTitle("Edit Name")
            .onAppear {
                fullName = userViewModel.user?.fullName ?? ""
            }
    }
}
