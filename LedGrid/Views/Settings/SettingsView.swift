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
    
    func presentShareSheet() {
        guard let userId = Utility.user?.id,
              let url = URL(string: "https://www.pixee-app.com/user/\(userId)") else { return }
        let message = "Add me on Pixee to share pixel art!"
        let activityVC = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            
        windowScene?.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    var body: some View {
        NavigationView {
            List {
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
                            presentShareSheet()
                        } label: {
                            Image(systemName: "person.badge.plus")
                                .font(.title3)
                        }
                    }
                }
                
                Section("Widgets") {
                    Button {
                        showWidgetModal = true
                    } label: {
                        Text("How to add a widget")
                    }
                }
                
                Section {
                    Button {
                        showEmailModal = true
                    } label: {
                        Text("Send Feedback")
                    }
                }
            }
            .sheet(isPresented: $showEmailModal) {
                MailView(recipient: "ted_bennett@icloud.com", subject: "Pixee Feedback", body: "Please enter your feedback below:\n\n\n\n\nThank you for leaving feedback and helping to improve Pixee!\n\nTed")
            }
            .sheet(isPresented: $showWidgetModal) {
                WidgetTutorialView(presented: $showWidgetModal)
            }
            .navigationTitle("Settings").toolbar {
                Button {
                    UserManager.shared.logout()
                    loggedIn = false
                } label: {
                    Text("Logout")
                }
            }.refreshable {
                await UserManager.shared.refreshFriends()
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
