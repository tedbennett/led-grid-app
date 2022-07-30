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
    private init() { }
    @Published var sentGrids = Utility.sentGrids {
        didSet {
            Utility.sentGrids = sentGrids
        }
    }
    
    @Published var receivedGrids = Utility.receivedGrids {
        didSet {
            Utility.receivedGrids = receivedGrids
        }
    }
    
    private func toHex(_ grid: [[Color]]) -> [[String]] {
        return grid.map { row in row.map { $0.hex } }
    }
    
    func sendGrid(_ grid: [[Color]], to users: [String]) async -> Bool {
        let id = UUID().uuidString
        let colorGrid = ColorGrid(id: id, grid: grid)
        await MainActor.run {
            sentGrids.insert(colorGrid, at: 0)
        }
        
        do {
            try await NetworkManager.shared.createGrid(id: id, grid: toHex(grid))
            for user in users {
                try await NetworkManager.shared.sendGrid(id: id, to: user)
            }
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func refreshReceivedGrids() async {
        do {
            let pixels = try await NetworkManager.shared.getGrids(after: nil)
            await MainActor.run {
                receivedGrids = pixels.map { ColorGrid(pixelArt: $0) }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func handleReceivedNotification() async {
        await refreshReceivedGrids()
    }
}