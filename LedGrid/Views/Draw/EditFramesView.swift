//
//  EditFramesView.swift
//  LedGrid
//
//  Created by Ted on 12/08/2022.
//

import SwiftUI

struct EditFramesView: View {
    @EnvironmentObject var drawViewModel: DrawViewModel
    @Binding var isOpened: Bool
    @StateObject var viewModel = EditFramesViewModel()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    Text("Tap a frame to edit • Drag to reorder").foregroundColor(.gray).font(.callout)
                    LazyVGrid(columns: columns) {
                        ReorderableForEach(items: viewModel.frames) { frame in
                            VStack {
                                HStack {
                                    Button {
                                        viewModel.duplicateFrame(frame)
                                        drawViewModel.duplicateGrid(frame.grid)
                                    } label: {
                                        Image(systemName: "plus.circle.fill").font(.title2)
                                    }
                                        .disabled(viewModel.frames.count > 7)
                                    Spacer()
                                    
                                    if viewModel.frames.count > 1 {
                                        Button {
                                            guard let index = viewModel.removeFrame(frame.id) else { return }
                                            drawViewModel.removeGrid(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill").font(.title2)
                                        }
                                        
                                    }
                                }.padding(.horizontal, 5)
                                    .padding(.top, 5)
                                GridView(grid: frame.grid, viewSize: .small)
                                    .drawingGroup()
                                    .onTapGesture {
                                        guard let index = viewModel.frames.firstIndex(where: { $0.id == frame.id }) else { return }
                                        drawViewModel.changeToGrid(at: index)
                                        isOpened = false
                                    }.padding(.horizontal)
                                    .padding(.bottom)
                            }
                            
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray5)))
                            .padding(10)
                        } moveAction: { from, to in
                            viewModel.moveFrame(from: from.first!, to: to)
                        } dropAction: { start, end in
                            drawViewModel.moveGrid(from: start, to: end)
                        }
                        Button {
                            viewModel.frames.append(Frame(grid: drawViewModel.currentGrid.size.blankGrid))
                            drawViewModel.newBlankGrid()
                            isOpened = false
                        } label: {
                            ZStack {
                                GridView(grid: GridSize.small.blankGrid, viewSize: .small)
                                    .padding()
                                    .opacity(0)
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray5)))
                                Image(systemName: "plus").font(.title)
                            }
                            
                        }.padding(10).disabled(viewModel.frames.count >= 8)
                    }
                }
                .navigationTitle("Frames")
                .toolbar {
                    Button {
                        isOpened = false
                    } label: {
                        Text("Done")
                    }
                }
            }.onAppear {
                drawViewModel.grids[drawViewModel.currentGridIndex] = drawViewModel.currentGrid
                viewModel.frames = drawViewModel.grids.map { Frame(grid: $0) }
//                viewModel.currentFrameId = viewModel.frames[drawViewModel.currentGridIndex].id
            }
        }.tint(Color(uiColor: .label))
    }
}



class EditFramesViewModel: ObservableObject {
    @Published var frames: [Frame] = []
    @Published var currentFrameId: String?
    
    func moveFrame(from origin: Int, to destination: Int) {
        let moved = frames.remove(at: origin)
        frames.insert(moved, at: origin > destination ? destination : destination - 1)
    }
    
    func duplicateFrame(_ frame: Frame) {
        let duplicate = Frame(grid: frame.grid)
        withAnimation {
            frames.append(duplicate)
        }
    }
    
    func removeFrame(_ id: String) -> Int? {
        guard let index = frames.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        withAnimation {
            _ = frames.remove(at: index)
        }
        return index
    }
}

struct ReorderableForEach<Content: View, Item: Identifiable & Equatable>: View {
    let items: [Item]
    let content: (Item) -> Content
    let moveAction: (IndexSet, Int) -> Void
    let dropAction: (Int, Int) -> Void
    
    // A little hack that is needed in order to make view back opaque
    // if the drag and drop hasn't ever changed the position
    // Without this hack the item remains semi-transparent
    @State private var hasChangedLocation: Bool = false
    
    init(
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content,
        moveAction: @escaping (IndexSet, Int) -> Void,
        dropAction: @escaping (Int, Int) -> Void
    ) {
        self.items = items
        self.content = content
        self.moveAction = moveAction
        self.dropAction = dropAction
    }
    
    @State private var draggingItem: Item?
    @State private var startPosition: Int?
    @State private var endPosition: Int?
    
    var body: some View {
        ForEach(items) { item in
            content(item)
                .opacity(draggingItem == item && hasChangedLocation ? 0.3 : 1)
                .onDrag {
                    draggingItem = item
                    startPosition = items.firstIndex(of: item)
                    return NSItemProvider(object: "\(item.id)" as NSString)
                }
                .onDrop(
                    of: [.text],
                    delegate: DragRelocateDelegate(
                        item: item,
                        listData: items,
                        current: $draggingItem,
                        hasChangedLocation: $hasChangedLocation
                    ) { from, to in
                        endPosition = to
                        withAnimation {
                            moveAction(from, to)
                        }
                    } dropAction: {
                        guard let startPosition = startPosition, let endPosition = endPosition else { return }
                        dropAction(startPosition, endPosition)
                    }
                )
        }
    }
}

struct DragRelocateDelegate<Item: Equatable>: DropDelegate {
    let item: Item
    var listData: [Item]
    @Binding var current: Item?
    @Binding var hasChangedLocation: Bool
    
    var moveAction: (IndexSet, Int) -> Void
    var dropAction: () -> Void
    
    func dropEntered(info: DropInfo) {
        guard item != current, let current = current else { return }
        guard let from = listData.firstIndex(of: current), let to = listData.firstIndex(of: item) else { return }
        
        hasChangedLocation = true
        
        if listData[to] != current {
            moveAction(IndexSet(integer: from), to > from ? to + 1 : to)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        hasChangedLocation = false
        current = nil
        dropAction()
        return true
    }
}
