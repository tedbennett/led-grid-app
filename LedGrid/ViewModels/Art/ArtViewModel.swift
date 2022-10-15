//
//  ArtViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/09/2022.
//

import SwiftUI

class ArtViewModel: ObservableObject {
    
    var model: ArtModel
    @Published var art: [String: [PixelArt]] = [:]
    @Published var badgeNumber = 0
    
    init() {
        model = ArtModel()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshArt),
            name: NSNotification.Name("REFRESH_ART"),
            object: nil
        )
        Task {
            await fetchArt()
            await refreshReceivedArt()
        }
    }
    
    func calculateBadgeNumber() {
        badgeNumber = art.values.reduce(0) { acc, artArray in
            acc + artArray.reduce(0) { $1.opened ? $0 : $0 + 1 }
        }
    }
    
    private func emptyMap() -> [String: [PixelArt]] {
        var map: [String: [PixelArt]] = [:]
        Utility.friends.forEach {
            map[$0.id] = []
        }
        return map
    }
    
    func fetchArt() async {
        let grids = await model.fetchArt()
        guard let userId = Utility.user?.id else { return }
        
        let mappedGrids: [String: [PixelArt]] = grids.reduce(into: emptyMap()) { map, grid in
            if grid.sender != userId {
                map[grid.sender, default: []].append(grid)
            } else {
                grid.receivers.forEach { receiver in
                    map[receiver, default: []].append(grid)
                }
            }
        }
        await MainActor.run {
            art = mappedGrids
            calculateBadgeNumber()
        }
    }
    
    @objc func refreshArt() async {
        _ = await model.fetchReceivedArt(since: Utility.lastReceivedFetchDate)
        Utility.lastReceivedFetchDate = Date()
        await fetchArt()
    }
    
    func addSentArt(_ art: PixelArt) async {
        await model.insertSentArt(art)
        await MainActor.run {
            art.receivers.forEach { receiver in
                self.art[receiver, default: []].insert(art, at: 0)
            }
        }
    }
    
    func refreshReceivedArt() async {
        let grids = await model.fetchReceivedArt(since: Utility.lastReceivedFetchDate)
        Utility.lastReceivedFetchDate = Date()
        await MainActor.run { [grids] in
            grids.forEach { grid in
                self.art[grid.sender, default: []].insert(grid, at: 0)
            }
            calculateBadgeNumber()
        }
    }
    
    func fetchAllArt() async {
        await model.fetchAllArt()
    }
    
    func toggleHideArt(id: String, friend: String) {
        model.hideArt(id: id)
        if let index = art[friend]?.firstIndex(where: { $0.id == id }) {
            art[friend]?[index].hidden.toggle()
        }
    }
    
    func setArtOpened(id: String, friend: String, opened: Bool) {
        model.openArt(id: id, opened: opened)
        if let index = art[friend]?.firstIndex(where: { $0.id == id }) {
            art[friend]?[index].opened = opened
        }
        calculateBadgeNumber()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func handleReceivedNotification() async {
        await refreshReceivedArt()
    }
    
    func removeAllArt() {
        model.removeAllArt()
        art = [:]
    }
}
