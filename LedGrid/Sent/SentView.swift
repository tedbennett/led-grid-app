//
//  SentView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI

struct SentView: View {
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
            ExpandedArtView(grid: grid, expandedGrid: $expandedGrid)
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
                            ForEach(manager.sentGrids.filter({ !$0.hidden })) { item in
                                if expandedGrid?.id != item.id {
                                    VStack {
                                        Button {
                                            withAnimation {
                                                expandedGrid = item
                                            }
                                        } label: {
                                            MiniGridView(grid: item.grid, viewSize: .small)
                                                .aspectRatio(contentMode: .fit)
                                                .drawingGroup()
                                        }.buttonStyle(.plain)
                                            .allowsHitTesting(expandedGrid == nil)
                                        HStack {
                                            Spacer()
                                            ForEach(item.receiver.prefix(item.receiver.count > 4 ? 3 : 4), id: \.self) { id in
                                                UserOrb(text: UserManager.shared.getInitials(for: id), isSelected: false)
                                                    .frame(width: 26, height: 26)
                                                    .padding(0)
                                            }
                                            if item.receiver.count > 4 {
                                                UserOrb(text: "+\(item.receiver.count - 3)", isSelected: false).frame(width: 26, height: 26)
                                            }
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
                                                    GridManager.shared.toggleHideSentGrid(id: item.id)
                                                }
                                            }
                                        }
                                        
                                } else {
                                    Rectangle().fill(Color(uiColor: .systemBackground)).frame(width:( geometry.size.width - 60) / 2).opacity(0.05)
                                }
                                
                            }
                        }
                        .padding(.horizontal)
                        
                    }.navigationTitle(expandedGrid == nil ? "Sent Grids" : "")
                        .blur(radius: expandedGrid == nil ? 0 : 20)
                }
                
                if let expandedGrid = expandedGrid {
                    expandedView(grid: expandedGrid).frame(width: geometry.size.width, height: geometry.size.height).zIndex(9999)
                }
            }
        }
    }
}

struct SentView_Previews: PreviewProvider {
    static var previews: some View {
        SentView()
    }
}

struct ExpandedArtView: View {
    var grid: ColorGrid
    @Binding var expandedGrid: ColorGrid?
    
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
            MiniGridView(grid: grid.grid, viewSize: .large)
                .drawingGroup()
                .aspectRatio(contentMode: .fit)
                .gesture(DragGesture().onChanged { val in
                    if val.translation.height > 50.0 {
                        withAnimation {
                            expandedGrid = nil
                        }
                    }
                })
            HStack {
                Text("SENT TO:")
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
