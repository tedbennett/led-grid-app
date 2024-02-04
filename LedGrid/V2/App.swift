//
//  App.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/06/2023.
//

import SwiftData
import SwiftUI

@main
struct AppV2: App {
    init() {}

    var body: some Scene {
        WindowGroup {
            Home()
        }.modelContainer(Container.modelContainer)
    }
}

