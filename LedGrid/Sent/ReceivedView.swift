//
//  ReceivedView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI

struct ReceivedView: View {
    @ObservedObject var manager = GridManager.shared
    @State private var expandedGrid: PixelArt?
    @Namespace private var gridAnimation
    
    @State private var showSentGrids = false
    @State private var fetchingGrids = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    func expandedView(grid: PixelArt) -> some View {
        VStack {
            Spacer()
            ExpandedReceivedArtView(grid: grid, expandedGrid: $expandedGrid)
                .matchedGeometryEffect(id: grid.id, in: gridAnimation)
            Spacer()
        }.padding(.horizontal, 20)
    }
    
    func gridDetails(_ item: PixelArt) -> some View {
        HStack {
            if item.grids.count > 1 {
                Label {
                    Text("\(item.grids.count)")
                } icon: {
                    Image(systemName: "square.stack.3d.up.fill")
                }.foregroundColor(.gray)
            }
            Spacer()
            UserOrb(text: UserManager.shared.getInitials(for: item.sender), isSelected: false)
                .frame(width: 26, height: 26)
                .padding(0)
            
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                NavigationView {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 30) {
                            ForEach(manager.receivedGrids) { item in
                                if expandedGrid?.id != item.id {
                                    VStack {
                                        Button {
                                            withAnimation {
                                                expandedGrid = item
                                            }
                                        } label: {
                                            ZStack {
                                                Text("Tap to View!").opacity(item.opened ? 0 : 1)
                                                MiniGridView(grid: item.grids[0], viewSize: .small)
                                                    .aspectRatio(contentMode: .fit)
                                                    .opacity(item.opened ? 1 : 0.001)
                                                VStack {
                                                    HStack {
                                                        Spacer()
                                                        Circle().fill(Color.red).frame(width: 15, height: 15)
                                                    }
                                                    Spacer()
                                                }.opacity(item.opened ? 0 : 1)
                                            }
                                        }.buttonStyle(.plain)
                                            .allowsHitTesting(expandedGrid == nil)
                                        gridDetails(item)
                                    }.padding()
                                        .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
                                        .drawingGroup()
                                        .matchedGeometryEffect(id: item.id, in: gridAnimation)
                                        .contextMenu {
                                            Button(
                                                item.hidden ? "Show" : "Hide",
                                                role: item.hidden ? .none : .destructive
                                            ) {
                                                withAnimation {
                                                    GridManager.shared.toggleHideReceivedGrid(id: item.id)
                                                }
                                            }
                                        }
                                } else {
                                    VStack {
                                        MiniGridView(grid: item.grids[0], viewSize: .small)
                                            .aspectRatio(contentMode: .fit)
                                        gridDetails(item)
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
                                    .opacity(0.001)
                                    .drawingGroup()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                    .navigationTitle(expandedGrid == nil ? "Received Art" : "")
                    .blur(radius: expandedGrid == nil ? 0 : 20)
                    
                    .onTapGesture {
                        if expandedGrid == nil { return }
                        withAnimation {
                            expandedGrid = nil
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                fetchingGrids = true
                                Task {
                                    await GridManager.shared.refreshReceivedGrids()
                                    await MainActor.run {
                                        fetchingGrids = false
                                    }
                                }
                            } label: {
                                Group {
                                    if fetchingGrids {
                                        Spinner()
                                    } else {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                    }
                                }
                            }.opacity(expandedGrid != nil ? 0 : 1)
                                .disabled(fetchingGrids)
                        }
                        ToolbarItemGroup() {
                            NavigationLink(isActive: $showSentGrids) {
                                SentView()
                            } label: {
                                HStack {
                                    Text("Sent Art")
                                    Image(systemName: "chevron.right")
                                }
                            }.opacity(expandedGrid != nil ? 0 : 1)
                        }
                    }
                }
                
                if let expandedGrid = expandedGrid {
                    expandedView(grid: expandedGrid).frame(width: geometry.size.width, height: geometry.size.height).zIndex(9999)
                }
            }
        }
    }
}

struct ExpandedReceivedArtView: View {
    var grid: PixelArt
    @Binding var expandedGrid: PixelArt?
    @State private var showCopyArtWarning = false
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State private var frameIndex = 0
    @State private var replay = false
    
    var body: some View {
        VStack {
            HStack {
                Text(grid.sentAt.formattedDate())
                    .foregroundColor(.gray)
                Spacer()
                
                Button {
                    showCopyArtWarning = true
                } label: {
                    Image(systemName: "square.on.square").font(.title2)
                }.buttonStyle(StandardButton(disabled: false))
                    .padding(.bottom, 10)
                    .padding(.trailing, 8)
                if grid.grids.count == 1 {
                    Button {
                        replay = true
                    } label: {
                        Image(systemName: "play").font(.title2)
                    }.buttonStyle(StandardButton(disabled: false))
                        .padding(.bottom, 10)
                        .padding(.trailing, 8)
                }
                Button {
                    withAnimation {
                        expandedGrid = nil
                    }
                } label: {
                    Image(systemName: "xmark").font(.title2)
                }.buttonStyle(StandardButton(disabled: false))
                    .padding(.bottom, 10)
            }
            if !replay && (grid.opened || grid.grids.count > 1) {
                MiniGridView(grid: grid.grids[frameIndex], viewSize: .large)
                //                    .drawingGroup()
                    .aspectRatio(contentMode: .fit)
                    .gesture(DragGesture().onChanged { val in
                        if val.translation.height > 50.0 {
                            withAnimation {
                                expandedGrid = nil
                            }
                        }
                    })
                    .onAppear {
                        if !grid.opened {
                            GridManager.shared.setGridOpened(id: grid.id, opened: true)
                        }
                    }
            } else {
                RevealView(grid: grid.grids[0]) {
                    replay = false
                    GridManager.shared.setGridOpened(id: grid.id, opened: true)
                }
                .aspectRatio(contentMode: .fit)
                .gesture(DragGesture().onChanged { val in
                    if val.translation.height > 50.0 {
                        withAnimation {
                            expandedGrid = nil
                        }
                    }
                })
            }
            
            HStack {
                Spacer()
                Text("FROM:")
                    .font(.system(.callout, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.leading, 10)
                
                UserOrb(text: UserManager.shared.getInitials(for: grid.sender), isSelected: false)
                    .frame(width: 50, height: 50)
                
            }
        }.padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
            .alert("Copy to canvas", isPresented: $showCopyArtWarning) {
                Button("Copy", role: .destructive) {
                    DrawManager.shared.copyReceivedGrid(grid)
                    NotificationManager.shared.selectedTab = 0
                }.accentColor(.white)
            } message: {
                Text("You are about to copy this pixel art to your canvas. This will erase the art you're currently drawing!")
            }
            .onReceive(timer) { time in
                frameIndex = frameIndex >= grid.grids.count - 1 ? 0 : frameIndex + 1
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
    }
}


struct ReceivedView_Previews: PreviewProvider {
    static var previews: some View {
        ReceivedView()
    }
}

struct RefreshableScrollView<Content: View>: View {
    var content: Content
    var onRefresh: () -> Void
    
    public init(content: @escaping () -> Content, onRefresh: @escaping () -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    public var body: some View {
        List {
            content
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .refreshable {
            onRefresh()
        }
    }
}
