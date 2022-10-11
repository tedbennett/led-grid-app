//
//  ArtListViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/10/2022.
//

import Foundation

class ArtListViewModel: ObservableObject {
    var user: User
    
    @Published var animatingId: String?
    @Published var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    init(user: User) {
        self.user = user
    }
    
    
    
    func setAnimatingArt(_ artId: String?) {
        animatingId = animatingId == artId ? nil : artId
    }
}
