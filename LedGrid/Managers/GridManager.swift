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
        let receivedFetch = PixelArt.fetchRequest()
        receivedFetch.predicate = NSPredicate(format: "sender != %@ AND hidden != true", user)
        receivedFetch.returnsDistinctResults = true
        receivedFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(PixelArt.sentAt), ascending: false)]
        receivedGrids = (try? PersistenceManager.shared.viewContext.fetch(receivedFetch)) ?? []

    }
    
    private func fetchSent() {
        guard let user = Utility.user?.id else { return }
        let sentFetch = PixelArt.fetchRequest()
        sentFetch.predicate = NSPredicate(format: "sender = %@ AND hidden != true", user)
        sentFetch.returnsDistinctResults = true
        sentFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(PixelArt.sentAt), ascending: false)]
        sentGrids = (try? PersistenceManager.shared.viewContext.fetch(sentFetch)) ?? []
        
    }
    
    private func toHex(_ grid: Grid) -> [[String]] {
        return grid.map { row in row.map { $0.hex } }
    }
    
    func sendGrid(_ grids: [Grid], title: String?, to users: [String]) async -> Bool {
        do {
            let _ = try await NetworkManager.shared.sendGrid(
                to: users,
                grids: grids.map { $0.hex() }
            )
            await MainActor.run {
                PersistenceManager.shared.save()
                fetchSent()
            }
            
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func refreshReceivedGrids(markOpened: Bool = false) async {
        do {
            let grids = try await NetworkManager.shared.getGrids(after: receivedGrids.isEmpty ? nil : Utility.lastReceivedFetchDate)
            Utility.lastReceivedFetchDate = Date()
            await MainActor.run {
                receivedGrids.insert(contentsOf: grids.map {
                    let grid = $0
                    grid.opened = markOpened
                    return grid
                }, at: 0)
                PersistenceManager.shared.save()
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
                PersistenceManager.shared.save()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func toggleHideSentGrid(id: String) {
        guard let grid = sentGrids.first(where: { $0.id == id }) else { return }
        grid.hidden.toggle()
        fetchSent()
        PersistenceManager.shared.save()
    }
    
    func toggleHideReceivedGrid(id: String) {
        guard let grid = receivedGrids.first(where: { $0.id == id }) else { return }
        grid.hidden.toggle()
        fetchReceived()
        PersistenceManager.shared.save()
    }
    
    func setGridOpened(id: String, opened: Bool) {
        guard let grid = receivedGrids.first(where: { $0.id == id }) else { return }
        grid.opened = opened
        
        fetchReceived()
        PersistenceManager.shared.save()
    }
    
    func handleReceivedNotification() async {
        await refreshReceivedGrids()
    }
    
    func removeAllGrids() {
        let fetch: NSFetchRequest<NSFetchRequestResult> = PixelArt.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetch
        )
        _ = try? PersistenceManager.shared.viewContext.execute(deleteRequest)
        PersistenceManager.shared.save()
        receivedGrids = []
        sentGrids = []
    }
}
