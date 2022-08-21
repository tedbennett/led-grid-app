//
//  DrawView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI
import AlertToast

struct DrawView: View {
    @ObservedObject var manager = DrawManager.shared
    @StateObject var viewModel = DrawViewModel()
    @Environment(\.scenePhase) var scenePhase
    @Namespace private var gridAnimation
    
    @State private var showSendView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    GridTopBarView(viewModel: viewModel, showSendView: $showSendView)
                        .padding(.top, 0)
                        .padding(.bottom, 10)
                    GridView(viewModel: viewModel)
                        .drawingGroup()
                        .padding(.bottom, 10)
                    ColorPickerView(viewModel: viewModel)
                        .padding(.bottom, 30)
                    GridActionsView(viewModel: viewModel)
                        .padding(.bottom, 20)
                    Spacer()
                    
                }
                
                .blur(radius: showSendView ? 20 : 0)
                .onTapGesture {
                    if !showSendView { return }
                    withAnimation {
                        showSendView = false
                    }
                }
                .allowsHitTesting(!showSendView)
                if showSendView {
                    ExpandedSendView( isOpened: $showSendView, viewModel: viewModel, namespace: gridAnimation)
                        .padding(10)
                        .transition(AnyTransition.move(edge: .bottom))
                        .zIndex(99)
                }
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
                .toast(isPresenting: $viewModel.showColorChangeToast, duration: 1.0) {
                    AlertToast(displayMode: .hud, type: .complete(.white), title: "Color copied!")
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

struct GridTopBarView: View {
    @ObservedObject var viewModel: DrawViewModel
    @ObservedObject var manager = DrawManager.shared
    @State private var showChangeSizeWarning = false
    @State private var showChangeSizeDialog = false
    @Binding var showSendView: Bool
    
    var body: some View {
        ZStack {
            if manager.grids.count > 1 {
                HStack {
                    Spacer()
                    
                    Text("Frame \(manager.currentGridIndex + 1)/\(manager.grids.count)").font(.caption).foregroundColor(.gray).padding(0)
                    Spacer()
                }
                
            }
            HStack {
                Menu {
                    Button {
                        if !viewModel.isGridBlank {
                            showChangeSizeWarning = true
                        } else {
                            showChangeSizeDialog = true
                        }
                    } label: {
                        Text("Change Size")
                    }
                    
                    Button(role: .destructive) {
                        viewModel.clearGrid()
                    } label: {
                        Text("Clear")
                    }.buttonStyle(StandardButton(disabled: false))
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(.title3, design: .rounded))
                        .padding(5)
                        .padding(.horizontal, 6)
                }
                
                Spacer()
                Button {
                    withAnimation {
                        showSendView = true
                    }
                } label: {
                    Label { Text("Send") } icon: { Image(systemName: "paperplane.fill") }
                        .font(.system(.title3, design: .rounded).bold())
                }
            }
        }.padding(.top, 0)
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

struct GridActionsView: View {
    @ObservedObject var manager = DrawManager.shared
    @ObservedObject var viewModel: DrawViewModel
    @State private var showEditFrames = false
    
    
    var body: some View {
        HStack {
            Button {
                showEditFrames = true
            } label: {
                Label {
                    Text("Frames").font(.system(.title3, design: .rounded)).fontWeight(.medium)
                } icon: {
                    Image(systemName: "square.stack.3d.up.fill")
                }
            }.buttonStyle(StandardButton(disabled: false))
            Spacer()
            Button {
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward").font(.system(.title3, design: .rounded).weight(.medium))
                    .padding(4)
            }.buttonStyle(StandardButton(disabled: manager.undoStates.isEmpty))
            
            Button {
                viewModel.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward").font(.system(.title3, design: .rounded).weight(.medium))
                    .padding(4)
            }.buttonStyle(StandardButton(disabled: manager.redoStates.isEmpty))
        }.padding(.vertical, -20)
            .sheet(isPresented: $showEditFrames) {
                EditFramesView(isOpened: $showEditFrames)
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
