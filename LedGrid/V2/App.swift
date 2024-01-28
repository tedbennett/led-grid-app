//
//  App.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/06/2023.
//

import SwiftUI
import SwiftData

@main
struct AppV2: App {
    init() {
    }
    var body: some Scene {
        WindowGroup {
            Home()
        }.modelContainer(Persistence.container)
            
    }
}

struct Persistence {
    static let container = try! ModelContainer(for: 
                                                //        SentArt.self,
                                               //        ReceivedArt.self,
                                               DraftArt.self
                                               //        Friend.self
    )
}

