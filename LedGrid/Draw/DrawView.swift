//
//  DrawView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI
import AlertToast
import Sliders

struct DrawView: View {
    @StateObject var viewModel = DrawViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                HStack {
                    Button {
                        viewModel.clearGrid()
                    } label: {
                        Text("Clear").font(.system(.title3, design: .rounded).bold())
                            .foregroundColor(.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }.background(Color.red.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.vertical, 0)
                        .padding(.leading, 20)
                    
                    Spacer()
                    Button {
                        viewModel.undo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward").font(.system(.title3, design: .rounded).bold())
                            .padding(4)
                    }.background(Color.blue.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.vertical, 0)
                        .disabled(viewModel.undoStates.isEmpty)
                    Button {
                        viewModel.redo()
                    } label: {
                        Image(systemName: "arrow.uturn.forward").font(.system(.title3, design: .rounded).bold())
                            .padding(4)
                    }.background(Color.blue.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.vertical, 0)
                        .padding(.trailing, 20)
                        .disabled(viewModel.redoStates.isEmpty)
                }.padding(.vertical, -20)
                GridView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                ColorPickerView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                SendView(viewModel: viewModel)
                    .frame(height: 75)
                    .padding(.horizontal, 20)
            }
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


struct ColorPickerSlider: View {
    @Binding var value: Double
    
    var body: some View {
        CustomSlider(value: $value, colors: [
            Color(UIColor.red),
            Color(UIColor.yellow),
            Color(UIColor.green),
            Color(UIColor.cyan),
            Color(UIColor.blue),
            Color(UIColor.purple),
            Color(UIColor.red)
        ])
    }
}

struct OpacityPickerSlider: View {
    @Binding var value: Double
    
    var body: some View {
        CustomSlider(value: $value, colors: [
            Color(UIColor.black),
            Color(UIColor.white)
        ])
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
            }.disabled(viewModel.selectedUsers.isEmpty || viewModel.sendingGrid)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(15)
        }
    }
}


struct CustomSlider: View {
    @Binding var value: Double
    var colors: [Color]
    var body: some View {
        ValueSlider(value: $value)
            .valueSliderStyle(HorizontalValueSliderStyle(
                track: HorizontalValueTrack(view: EmptyView())
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: colors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(RoundedRectangle(cornerRadius: 3).frame(height: 4))
                    ),
                thumb: DefaultThumb()
            )
            )
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
                                ZStack {
                                    Circle()
                                        .strokeBorder(Color.blue, lineWidth: selectedFriends.contains(where: { user.id == $0 }) ? 3 : 0)
                                        .background(Circle().foregroundColor(Color.gray))
                                        .frame(width: 50, height: 50)
                                    Text(user.fullName?.split(separator: " ").map { $0.prefix(1)}.joined().uppercased() ?? "?").font(.system(.body, design: .rounded).bold())
                                }
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
