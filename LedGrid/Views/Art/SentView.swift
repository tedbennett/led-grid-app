//
//  SentView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI

struct SentView: View {
    @ObservedObject var manager = GridManager.shared
    @State private var expandedGrid: PixelArt?
    @Namespace private var gridAnimation
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    func expandedView(grid: PixelArt) -> some View {
        VStack {
            Spacer()
            ExpandedArtView(grid: grid, expandedGrid: $expandedGrid)
                .matchedGeometryEffect(id: grid.id, in: gridAnimation)
            Spacer()
        }.padding(.horizontal, 20)
    }
    
    func gridDetails(_ item: PixelArt) -> some View {
        HStack {
            if item.grids.count > 1 {
                Image(systemName: "square.stack.3d.up.fill")
                    .padding(.trailing, -3)
                    .foregroundColor(.gray)
                    .font(.callout)
                
                Text("\(item.grids.count)")
                    .padding(0)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            Spacer()
            ForEach(item.receivers.prefix(item.receivers.count > 3 ? 2 : 3), id: \.self) { id in
                UserOrb(text: UserManager.shared.getInitials(for: id), isSelected: false)
                    .frame(width: 26, height: 26)
                    .padding(0)
            }
            if item.receivers.count > 3 {
                UserOrb(text: "+\(item.receivers.count - 2)", isSelected: false).frame(width: 26, height: 26)
            }
        }
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
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
                                        MiniGridView(grid: item.grids[0], viewSize: .small)
                                            .aspectRatio(contentMode: .fit)
                                    }.buttonStyle(.plain)
                                        .allowsHitTesting(expandedGrid == nil)
                                    gridDetails(item)
                                }.padding()
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
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
                                    .drawingGroup()
                                    .matchedGeometryEffect(id: item.id, in: gridAnimation)
                            } else {
                                VStack {
                                    MiniGridView(grid: item.grids[0], viewSize: .small)
                                        .aspectRatio(contentMode: .fit)
                                    gridDetails(item)
                                }.padding()
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
                                    .opacity(0.001)
                            }
                        }
                    }
                    .padding(.horizontal)
                }.navigationTitle(expandedGrid == nil ? "Sent Art" : "")
                    .blur(radius: expandedGrid == nil ? 0 : 20)
                    .onTapGesture {
                        if expandedGrid == nil { return }
                        withAnimation {
                            expandedGrid = nil
                        }
                    }
                    .navigationBarBackButtonHidden(expandedGrid != nil)
            }
            
            if let expandedGrid = expandedGrid {
                expandedView(grid: expandedGrid).frame(width: geometry.size.width, height: geometry.size.height).zIndex(9999)
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
    var grid: PixelArt
    @Binding var expandedGrid: PixelArt?
    @State private var showCopyArtWarning = false
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State private var frameIndex = 0
    
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
                Button {
                    withAnimation {
                        expandedGrid = nil
                    }
                } label: {
                    Image(systemName: "xmark").font(.title2)
                }.buttonStyle(StandardButton(disabled: false))
                    .padding(.bottom, 10)
            }
            MiniGridView(grid: grid.grids[frameIndex], viewSize: .large)
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
                        ForEach(grid.receivers, id: \.self) { id in
                            UserOrb(text: UserManager.shared.getInitials(for: id), isSelected: false)
                                .frame(width: 50, height: 50)
                        }
                    }.frame(height: 60, alignment: .trailing)
                }.padding(0)
            }
        }.padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
            .onReceive(timer) { time in
                frameIndex = frameIndex >= grid.grids.count - 1 ? 0 : frameIndex + 1
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
            .alert("Copy to canvas", isPresented: $showCopyArtWarning) {
                Button("Copy", role: .destructive) {
                    DrawManager.shared.copyReceivedGrid(grid)
                    NotificationManager.shared.selectedTab = 0
                }.accentColor(.white)
            } message: {
                Text("You are about to copy this pixel art to your canvas. This will erase the art you're currently drawing!")
            }
    }
}
