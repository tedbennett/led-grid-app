//
//  ReceivedView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI

struct ReceivedView: View {
    @ObservedObject var manager = GridManager.shared
    @State private var expandedGrid: ColorGrid?
    @Namespace private var gridAnimation
    
    @State private var showSentGrids = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    func expandedView(grid: ColorGrid) -> some View {
        VStack {
            Spacer()
            ExpandedReceivedArtView(grid: grid, expandedGrid: $expandedGrid)
                .matchedGeometryEffect(id: grid.id, in: gridAnimation)
            Spacer()
        }.padding(.horizontal, 20)
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                NavigationView {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 30) {
                            ForEach(manager.receivedGrids.filter({ !$0.hidden })) { item in
                                if expandedGrid?.id != item.id {
                                    VStack {
                                        Button {
                                            withAnimation {
                                                expandedGrid = item
                                            }
                                        } label: {
                                            if item.opened {
                                                MiniGridView(grid: item.grid, viewSize: .small)
                                                    .aspectRatio(contentMode: .fit)
                                                    .drawingGroup()
                                            } else {
                                                ZStack {
                                                    MiniGridView(grid: Array(repeating:  Array(repeating: .clear, count: item.grid.count), count: item.grid.count), viewSize: .small).opacity(0.001)
                                                        .aspectRatio(contentMode: .fit)
                                                    Text("Tap to View!")
                                                    VStack {
                                                    HStack {
                                                        Spacer()
                                                        Circle().fill(Color.red).frame(width: 15, height: 15)
                                                    }
                                                        Spacer()
                                                    }
                                                }
                                            }
                                        }.buttonStyle(.plain)
                                            .allowsHitTesting(expandedGrid == nil)
                                        HStack {
                                            Spacer()
                                            UserOrb(text: UserManager.shared.getInitials(for: item.sender), isSelected: false)
                                                .frame(width: 26, height: 26)
                                                .padding(0)
                                            
                                        }
                                    }
                                    .matchedGeometryEffect(id: item.id, in: gridAnimation).padding()
                                        .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
                                    
                                        .frame(width:( geometry.size.width - 60) / 2)
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
                                    Rectangle().fill(Color(uiColor: .systemBackground)).frame(width:( geometry.size.width - 60) / 2).opacity(0.05)
                                }
                                
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                    //                onRefresh: {
                    //                        Task {
                    //                            await GridManager.shared.refreshReceivedGrids()
                    //                        }
                    //                    }
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
                                Task {
                                    await GridManager.shared.refreshReceivedGrids()
                                }
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }.opacity(expandedGrid != nil ? 0 : 1)
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
    var grid: ColorGrid
    @Binding var expandedGrid: ColorGrid?
    @State private var showChangeSizeWarning = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        expandedGrid = nil
                    }
                } label: {
                    Image(systemName: "xmark").font(.title2)
                }.buttonStyle(StandardButton(disabled: false))
                    .padding(.bottom, 10)
            }
            if grid.opened {
                MiniGridView(grid: grid.grid, viewSize: .large)
//                    .drawingGroup()
                    .aspectRatio(contentMode: .fit)
                    .gesture(DragGesture().onChanged { val in
                        if val.translation.height > 50.0 {
                            withAnimation {
                                expandedGrid = nil
                            }
                        }
                    })
            } else {
                RevealView(grid: grid.grid)
                    .aspectRatio(contentMode: .fit)
                    .onAppear {
                        GridManager.shared.markGridOpened(id: grid.id)
                    }
                    .gesture(DragGesture().onChanged { val in
                        if val.translation.height > 50.0 {
                            withAnimation {
                                expandedGrid = nil
                            }
                        }
                    })
            }
            
            HStack {
                Button {
                    showChangeSizeWarning = true
                } label: {
                    Text("Edit")
                }.buttonStyle(StandardButton(disabled: false))
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
            .alert("Warning", isPresented: $showChangeSizeWarning) {
                Button("Copy", role: .destructive) {
                    DrawManager.shared.copyReceviedGrid(grid)
                    NotificationManager.shared.selectedTab = 0
                }.accentColor(.white)
            } message: {
                Text("Copying this art will erase your current canvas!")
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
