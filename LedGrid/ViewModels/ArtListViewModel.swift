//
//  ArtListViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/10/2022.
//

import SwiftUI
import Combine

class ArtListViewModel: ObservableObject {
    
    @Published var showUpgradeView: Bool = false
    @Published var animatingId: String?
    @Published var widgetArtId: String?
    
    @Published var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    func setAnimatingArt(_ artId: String?) {
        animatingId = animatingId == artId ? nil : artId
    }
    
}
