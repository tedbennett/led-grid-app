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
    
    
    
    @AppStorage(UDKeys.haptics.rawValue, store: Utility.store) var haptics = true
    @AppStorage(UDKeys.spinningLogo.rawValue, store: Utility.store) var spinner = true
    @AppStorage(UDKeys.showGuides.rawValue, store: Utility.store) var showGuides = true
    
    @FetchRequest(sortDescriptors: []) var friends: FetchedResults<User>
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section("Your Details") {
                        NavigationLink(userViewModel.user?.fullName ?? "Unknown name", isActive: $showEditView) {
                            EditNameView(isPresented: $showEditView)
                        }
                        Text(userViewModel.user?.email ?? "Unknown email").foregroundColor(.gray)
                        NavigationLink {
                            FriendsSettingsView(friends: Array(friends))
                        } label: {
                            HStack {
                                Text("Friends")
                                Spacer()
                                Text("\(friends.count)").foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section("Preferences") {
                        NavigationLink("Colour Picker") {
                            ColorPickerSettingsView()
                        }
                        Toggle("Haptic Feedback", isOn: $haptics)
                        Toggle("Draw View Spinner", isOn: $spinner)
                        Toggle("Draw View Guides", isOn: $showGuides)
                    }
                    
                    
                    Section("About Pixee") {
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
                    
                    Section("Account Actions") {
                        Button(role: .destructive) {
                            loggedIn = false
                            userViewModel.logout()
                        } label: {
                            Label {
                                Text("Logout")
                            } icon: {
                                Image(systemName: "door.left.hand.open").foregroundColor(.red)
                            }
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAccountAlert = true
                        } label: {
                            Label {
                                Text("Delete Account")
                            } icon: {
                                Image(systemName: "xmark.octagon").foregroundColor(.red)
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
            }.navigationTitle("Settings")
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
            .onChange(of: haptics) { _ in
                print(haptics)
            }
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView(loggedIn: .constant(true))
//            .environmentObject(UserViewModel())
//    }
//}

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
