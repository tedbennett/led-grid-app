//
//  SettingsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @ObservedObject var manager = UserManager.shared
    @Binding var loggedIn: Bool
    @State private var friends = Utility.friends
    @State private var showEditView = false
    @State private var showEmailModal = false
    @State private var showWidgetModal = false
    @State private var showUpgradeView = false
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section {
                        if manager.friends.isEmpty {
                            Button {
                                Helpers.presentShareSheet()
                            } label: {
                                Text("Add friends to get started!")
                            }
                        }
                        ForEach(manager.friends) { friend in
                            Text(friend.fullName ?? "Unknown Friend")
                                .swipeActions(allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        manager.removeFriend(id: friend.id)
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
                        Text(UserManager.shared.user?.fullName ?? "Unknown name")
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
                        Text(UserManager.shared.user?.email ?? "Unknown email").foregroundColor(.gray)
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
                    await UserManager.shared.refreshFriends()
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
                        UserManager.shared.logout()
                        loggedIn = false
                    } label: {
                        Text("Logout")
                    }
                    
                    Button(role: .destructive) {
                        showDeleteAccountAlert = true
                    } label: {
                        Text("Delete Account")
                    }.buttonStyle(StandardButton(disabled: false))
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
                    Task {
                        do {
                            try await NetworkManager.shared.deleteAccount()
                        } catch {
                            print("Error deleting account: \(error.localizedDescription)")
                        }
                    }
                    loggedIn = false
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
    }
}

struct EditNameView: View {
    @Binding var isPresented: Bool
    @State private var fullName = UserManager.shared.user?.fullName ?? ""
    var body: some View {
        Form {
            Section("Full Name") {
                TextField("Full Name", text: $fullName)
            }
            Button {
                Task {
                    await UserManager.shared.updateUser(fullName: fullName)
                }
                isPresented = false
            } label: {
                Text("Save")
            }
        }.navigationTitle("Edit Name")
    }
}
