//
//  EditFramesView.swift
//  LedGrid
//
//  Created by Ted on 12/08/2022.
//

import SwiftUI

struct EditFramesView: View {
    @ObservedObject var manager = DrawManager.shared
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
                            ZStack {
                                MiniGridView(grid: frame.grid, viewSize: .small)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray5)))
                                    .onTapGesture {
                                        guard !viewModel.editMode, let index = viewModel.frames.firstIndex(where: { $0.id == frame.id }) else { return }
                                        DrawManager.shared.changeToGrid(at: index)
                                        isOpened = false
                                    }
                                VStack {
                                    HStack {
                                        Button {
                                            viewModel.duplicateFrame(frame.id)
                                        } label: {
                                            Image(systemName: "plus.circle.fill").font(.title2)
                                        }.padding(2)
                                            .disabled(viewModel.frames.count > 7)
                                        Spacer()
                                        
                                        if viewModel.frames.count > 1 {
                                            Button {
                                                viewModel.removeFrame(frame.id)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill").font(.title2)
                                            }.padding(2)
                                            
                                        }
                                    }
                                    Spacer()
                                }
                            }.padding(10)
                        } moveAction: { from, to in
                            viewModel.moveFrame(from: from.first!, to: to)
                        } dropAction: { viewModel.commitDrop() }
                        Button {
                            manager.grids.append(manager.currentGrid.size.blankGrid)
                            manager.currentGridIndex = manager.grids.count - 1
                            isOpened = false
                        } label: {
                            ZStack {
                                MiniGridView(grid: GridSize.small.blankGrid, viewSize: .small)
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
                manager.grids[manager.currentGridIndex] = manager.currentGrid
                viewModel.currentFrameId = viewModel.frames[manager.currentGridIndex].id
            }.onChange(of: manager.grids, perform: { _ in
                viewModel.frames = manager.grids.map { Frame(grid: $0) }
                viewModel.currentFrameId = viewModel.frames[manager.currentGridIndex].id
            })
        }.tint(Color(uiColor: .label))
    }
}



class EditFramesViewModel: ObservableObject {
    @Published var frames: [Frame] = DrawManager.shared.grids.map { Frame(grid: $0) }
    @Published var draggedFrame: Frame?
    @Published var editMode = false
    @Published var currentFrameId: String?
    
    func moveFrame(from origin: Int, to destination: Int) {
        let moved = frames.remove(at: origin)
        frames.insert(moved, at: origin > destination ? destination : destination - 1)
    }
    
    func commitDrop() {
        DrawManager.shared.grids = frames.map { $0.grid }
        guard let id = currentFrameId,
              let index = frames.firstIndex(where: { $0.id == id }) else {
            return
        }
        DrawManager.shared.currentGridIndex = index
    }
    
    func duplicateFrame(_ id: String) {
        guard let index = frames.firstIndex(where: { $0.id == id }) else {
            return
        }
        let duplicate = Frame(grid: frames[index].grid)
        withAnimation {
            frames.append(duplicate)
        }
        DrawManager.shared.grids.append(DrawManager.shared.grids[index])
    }
    
    func removeFrame(_ id: String) {
        guard let index = frames.firstIndex(where: { $0.id == id }) else {
            return
        }
        if index == DrawManager.shared.currentGridIndex {
            DrawManager.shared.currentGridIndex = 0
        } else if index < DrawManager.shared.currentGridIndex {
            DrawManager.shared.currentGridIndex -= 1
        }
        _ = withAnimation {
            frames.remove(at: index)
        }
        DrawManager.shared.grids.remove(at: index)
        DrawManager.shared.currentGridIndex = DrawManager.shared.currentGridIndex
    }
}

struct ReorderableForEach<Content: View, Item: Identifiable & Equatable>: View {
    let items: [Item]
    let content: (Item) -> Content
    let moveAction: (IndexSet, Int) -> Void
    let dropAction: () -> Void
    
    // A little hack that is needed in order to make view back opaque
    // if the drag and drop hasn't ever changed the position
    // Without this hack the item remains semi-transparent
    @State private var hasChangedLocation: Bool = false
    
    init(
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content,
        moveAction: @escaping (IndexSet, Int) -> Void,
        dropAction: @escaping () -> Void
    ) {
        self.items = items
        self.content = content
        self.moveAction = moveAction
        self.dropAction = dropAction
    }
    
    @State private var draggingItem: Item?
    
    var body: some View {
        ForEach(items) { item in
            content(item)
                .opacity(draggingItem == item && hasChangedLocation ? 0.3 : 1)
                .onDrag {
                    draggingItem = item
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
                        withAnimation {
                            moveAction(from, to)
                        }
                    } dropAction: { dropAction() }
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
