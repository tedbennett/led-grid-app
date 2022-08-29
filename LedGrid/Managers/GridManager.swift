//
//  GridManager.swift
//  LedGrid
//
//  Created by Ted on 29/07/2022.
//

import Foundation
import SwiftUI
import CoreData

class GridManager: ObservableObject {
    static var shared = GridManager()
    
    private init() {
        fetchReceived()
        fetchSent()
        
        Task {
            await refreshReceivedGrids()
        }
    }
    
    @Published var sentGrids: [PixelArt] = []
    @Published var receivedGrids: [PixelArt] = []
    
    private func fetchReceived() {
        guard let user = Utility.user?.id else { return }
        let receivedFetch = StoredPixelArt.fetchRequest()
        receivedFetch.predicate = NSPredicate(format: "sender != %@ AND hidden != true", user)
        receivedFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPixelArt.sentAt), ascending: false)]
        let fetched = (try? PersistenceManager.shared.viewContext.fetch(receivedFetch)) ?? []
        receivedGrids = fetched.map { PixelArt(from: $0) }

    }
    
    private func fetchSent() {
        guard let user = Utility.user?.id else { return }
        let sentFetch = StoredPixelArt.fetchRequest()
        sentFetch.predicate = NSPredicate(format: "sender = %@ AND hidden != true", user)
        sentFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPixelArt.sentAt), ascending: false)]
        let fetched = (try? PersistenceManager.shared.viewContext.fetch(sentFetch)) ?? []
        sentGrids = fetched.map { PixelArt(from: $0) }
        
    }
    
    private func toHex(_ grid: Grid) -> [[String]] {
        return grid.map { row in row.map { $0.hex } }
    }
    
    func sendGrid(_ grids: [Grid], title: String?, to users: [String]) async -> Bool {
        do {
            let art = try await NetworkManager.shared.sendGrid(
                to: users,
                grids: grids.map { $0.hex() }
            )
            await MainActor.run {
                sentGrids.insert(art, at: 0)
                let _ = StoredPixelArt(from: art, context: PersistenceManager.shared.viewContext)
                PersistenceManager.shared.save()
            }
            
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func refreshReceivedGrids(markOpened: Bool = false) async {
        do {
            var grids = try await NetworkManager.shared.getGrids(after: receivedGrids.isEmpty ? nil : Utility.lastReceivedFetchDate)
            if markOpened || (receivedGrids.isEmpty && grids.count > 4) {
                grids = grids.map {
                    var grid = $0
                    grid.opened = true
                    return grid
                }
            }
            Utility.lastReceivedFetchDate = Date()
            await MainActor.run { [grids] in
                receivedGrids.insert(contentsOf: grids, at: 0)
                if !grids.isEmpty {
                    let _ = grids.map { StoredPixelArt(from: $0, context: PersistenceManager.shared.viewContext) }
                    PersistenceManager.shared.save()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func refreshSentGrids() async {
        do {
            let grids = try await NetworkManager.shared.getSentGrids(after: nil)
            await MainActor.run {
                sentGrids = grids
                
                if !grids.isEmpty {
                    let _ = grids.map { StoredPixelArt(from: $0, context: PersistenceManager.shared.viewContext) }
                    PersistenceManager.shared.save()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func toggleHideSentGrid(id: String) {
        guard let index = sentGrids.firstIndex(where: { $0.id == id }) else { return }
        sentGrids[index].hidden.toggle()
        let fetch = StoredPixelArt.fetchRequest()
        fetch.predicate = NSPredicate(format: "id = %@", sentGrids[index].id)
        fetch.fetchLimit = 1
        guard let grid = (try? PersistenceManager.shared.viewContext.fetch(fetch))?.first else { return }
        grid.hidden.toggle()
        try? PersistenceManager.shared.viewContext.save()
    }
    
    func toggleHideReceivedGrid(id: String) {
        guard let index = receivedGrids.firstIndex(where: { $0.id == id }) else { return }
        receivedGrids[index].hidden.toggle()
        let fetch = StoredPixelArt.fetchRequest()
        fetch.predicate = NSPredicate(format: "id = %@", receivedGrids[index].id)
        fetch.fetchLimit = 1
        guard let grid = (try? PersistenceManager.shared.viewContext.fetch(fetch))?.first else { return }
        grid.hidden.toggle()
        try? PersistenceManager.shared.viewContext.save()
    }
    
    func setGridOpened(id: String, opened: Bool) {
        guard let index = receivedGrids.firstIndex(where: { $0.id == id }) else { return }
        receivedGrids[index].opened = opened
        let fetch = StoredPixelArt.fetchRequest()
        fetch.predicate = NSPredicate(format: "id = %@", receivedGrids[index].id)
        fetch.fetchLimit = 1
        guard let grid = (try? PersistenceManager.shared.viewContext.fetch(fetch))?.first else { return }
        grid.opened = opened
        try! PersistenceManager.shared.viewContext.save()
    }
    
    func handleReceivedNotification() async {
        await refreshReceivedGrids()
    }
    
    func removeAllGrids() {
        let fetch: NSFetchRequest<NSFetchRequestResult> = StoredPixelArt.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetch
        )
        _ = try? PersistenceManager.shared.viewContext.execute(deleteRequest)
        PersistenceManager.shared.save()
        receivedGrids = []
        sentGrids = []
    }
}

