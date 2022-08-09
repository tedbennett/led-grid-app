//
//  DrawView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI
import AlertToast

struct DrawView: View {
    @StateObject var viewModel = DrawViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                GridActionsView(viewModel: viewModel)
                GridView(viewModel: viewModel)
                ColorPickerView(viewModel: viewModel)
                SendView(viewModel: viewModel)
                    .frame(height: 75)
            }.padding(.horizontal, 20)
            .navigationTitle("Draw Something")
            .onAppear {
                viewModel.saveGrid()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive || newPhase == .background {
                    viewModel.saveGrid()
                }
            }
            .toast(isPresenting: $viewModel.sentGrid) {
                AlertToast(type: .complete(.gray), title: "Sent pixel art!")
            }
            .toast(isPresenting: $viewModel.failedToSendGrid) {
                AlertToast(type: .error(.gray), title: "Failed to send", subTitle: "Try again later.")
            }
        }
    }
}

struct DrawView_Previews: PreviewProvider {
    static var previews: some View {
        DrawView()
            .previewDevice("iPhone 13 mini")
    }
}

struct GridActionsView: View {
    @ObservedObject var viewModel: DrawViewModel
    
    @State private var showChangeSizeWarning = false
    @State private var showChangeSizeDialog = false
    
    var body: some View {
        HStack {
            Button {
                viewModel.clearGrid()
            } label: {
                Text("Clear").font(.system(.title3, design: .rounded)).fontWeight(.medium)
                    .padding(5)
                    .padding(.horizontal, 6)
            }.buttonStyle(StandardButton(disabled: false))
            Spacer()
            Button {
                if !viewModel.isGridBlank {
                    showChangeSizeWarning = true
                } else {
                    showChangeSizeDialog = true
                }
            } label: {
                Text("Change Size").font(.system(.title3, design: .rounded)).fontWeight(.medium)
                    .padding(5)
                    .padding(.horizontal, 6)
            }.buttonStyle(StandardButton(disabled: false))
//            Picker("", selection: $viewModel.gridSize) {
//                Text("8x8").tag(GridSize.small)
//                Text("12x12").tag(GridSize.medium)
//                Text("16x16").tag(GridSize.large)
//            }.pickerStyle(.segmented)
            Spacer()
            Button {
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward").font(.system(.title3, design: .rounded).weight(.medium))
                    .padding(4)
            }.buttonStyle(StandardButton(disabled: viewModel.undoStates.isEmpty))
                
            Button {
                viewModel.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward").font(.system(.title3, design: .rounded).weight(.medium))
                    .padding(4)
            }.buttonStyle(StandardButton(disabled: viewModel.redoStates.isEmpty))
        }.padding(.vertical, -20)
            .alert("Warning", isPresented: $showChangeSizeWarning) {
                Button("Ok", role: .destructive) { showChangeSizeDialog = true }.accentColor(.white)
            } message: {
                Text("Changing grid size will erase your current art!")
            }
            .confirmationDialog("Change grid size", isPresented: $showChangeSizeDialog) {
                Button("8x8") { viewModel.setGridSize(.small) }
                Button("12x12") { viewModel.setGridSize(.medium) }
                Button("16x16") { viewModel.setGridSize(.large) }
            }
    }
}

struct SendView: View {
    @ObservedObject var viewModel: DrawViewModel
    
    var body: some View {
        HStack {
            FriendsView(selectedFriends: $viewModel.selectedUsers)
            Button {
                viewModel.sendGrid()
            } label: {
                if viewModel.sendingGrid {
                    ProgressView()
                        .frame(width: 80, height: 60)
                } else {
                    Text("Send")
                        .font(.system(.title3, design: .rounded).bold())
                    
                        .frame(width: 80, height: 60)
                }
            }.buttonStyle(StandardButton(disabled: viewModel.selectedUsers.isEmpty || viewModel.sendingGrid))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.accentColor.opacity(viewModel.selectedUsers.isEmpty || viewModel.sendingGrid ? 0.5 : 1), lineWidth: 2)
                )
                .disabled(viewModel.selectedUsers.isEmpty || viewModel.sendingGrid)
        }
    }
}

struct FriendsView: View {
    @Binding var selectedFriends: [String]
    @ObservedObject var manager = UserManager.shared
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if manager.friends.isEmpty {
                        Text("Add some friends in settings to send art").font(.caption).foregroundColor(.gray)
                    } else {
                        ForEach(manager.friends) { user in
                            VStack {
                                Button {
                                    if selectedFriends.contains(where: { user.id == $0 }) {
                                        selectedFriends = selectedFriends.filter { user.id != $0 }
                                    } else {
                                        selectedFriends.append(user.id)
                                    }
                                    
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                } label: {
                                    UserOrb(text: user.fullName?
                                        .split(separator: " ")
                                        .map { $0.prefix(1) }
                                        .joined()
                                        .uppercased(), isSelected: selectedFriends.contains(where: { user.id == $0 }))
                                }.buttonStyle(.plain)
                                Text(user.fullName ?? "Unknown").font(.caption).foregroundColor(.gray)
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

struct StandardButton: ButtonStyle {
    var disabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.accentColor.opacity(disabled ? 0.5 : 1))
//            .background(Color.gray.opacity(0.2))
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(Color.accentColor.opacity(disabled ? 0.5 : 1), lineWidth: 2)
//            )
            .padding(.vertical, 0)
            .disabled(disabled)
    }
}
