//
//  GridManager.swift
//  LedGrid
//
//  Created by Ted on 29/07/2022.
//

import Foundation
import SwiftUI

class GridManager: ObservableObject {
    static var shared = GridManager()
    private init() {
        Task {
//            await refreshSentGrids()
            await refreshReceivedGrids()
        }
    }
    @Published var sentGrids = Utility.sentGrids {
        didSet {
            Utility.sentGrids = sentGrids
        }
    }
    
    @Published var receivedGrids = Utility.receivedGrids {
        didSet {
            Utility.receivedGrids = receivedGrids
            print( Utility.receivedGrids)
        }
    }
    
    private func toHex(_ grid: [[Color]]) -> [[String]] {
        return grid.map { row in row.map { $0.hex } }
    }
    
    func sendGrid(_ grid: [[Color]], to users: [String]) async -> Bool {
        guard let userId = Utility.user?.id else { return false }
        let id = UUID().uuidString
        let colorGrid = ColorGrid(id: id, grid: grid, sender: userId, receiver: users)
        
        do {
            try await NetworkManager.shared.sendGrid(
                id: id,
                to: users,
                grid: colorGrid.toHex(),
                gridSize: colorGrid.size
            )
            await MainActor.run {
                sentGrids.insert(colorGrid, at: 0)
            }
            
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func refreshReceivedGrids() async {
        do {
            let grids = try await NetworkManager.shared.getGrids(after: receivedGrids.isEmpty ? nil : Utility.lastReceivedFetchDate)
            Utility.lastReceivedFetchDate = Date()
            await MainActor.run {
                receivedGrids.insert(contentsOf: grids, at: 0)
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
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func toggleHideSentGrid(id: String) {
        guard let index = sentGrids.firstIndex(where: { $0.id == id }) else { return }
        sentGrids[index].hidden.toggle()
    }
    
    func toggleHideReceivedGrid(id: String) {
        guard let index = receivedGrids.firstIndex(where: { $0.id == id }) else { return }
        receivedGrids[index].hidden.toggle()
    }
    
    func markGridOpened(id: String) {
        guard let index = receivedGrids.firstIndex(where: { $0.id == id }) else { return }
        receivedGrids[index].opened = true
    }
    
    func handleReceivedNotification() async {
        await refreshReceivedGrids()
    }
}
