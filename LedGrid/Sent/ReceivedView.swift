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
                                                MiniGridView(grid: item.grid, strokeWidth: 0.5)
                                                    .aspectRatio(contentMode: .fit)
                                                    .drawingGroup()
                                            } else {
                                                ZStack {
                                                    MiniGridView(grid: Array(repeating:  Array(repeating: .clear, count: item.grid.count), count: item.grid.count), strokeWidth: 0.0)
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
                                    }.padding()
                                        .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
                                    
                                        .matchedGeometryEffect(id: item.id, in: gridAnimation)
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
                    .navigationTitle(expandedGrid == nil ? "Received Grids" : "")
                    .blur(radius: expandedGrid == nil ? 0 : 20)
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
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        GridManager.shared.markGridOpened(id: grid.id)
                        expandedGrid = nil
                    }
                } label: {
                    Image(systemName: "xmark").font(.title2)
                }.buttonStyle(StandardButton(disabled: false))
                    .padding(.bottom, 10)
            }
            if grid.opened {
                MiniGridView(grid: grid.grid, cornerRadius: 5)
                    .drawingGroup()
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
                    .gesture(DragGesture().onChanged { val in
                        if val.translation.height > 50.0 {
                            withAnimation {
                                GridManager.shared.markGridOpened(id: grid.id)
                                expandedGrid = nil
                            }
                        }
                    })
            }
            
            HStack {
                Text("FROM:")
                    .font(.system(.callout, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.leading, 10)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(grid.receiver, id: \.self) { id in
                            UserOrb(text: UserManager.shared.getInitials(for: id), isSelected: false)
                                .frame(width: 50, height: 50)
                        }
                    }.frame(height: 60, alignment: .trailing)
                }.padding(0)
            }
        }.padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
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
