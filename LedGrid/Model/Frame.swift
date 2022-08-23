//
//  Frame.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation

struct Frame: Identifiable, Codable, Equatable {
    var grid: Grid
    var id: String = UUID().uuidString
    
    static func == (lhs: Frame, rhs: Frame) -> Bool {
        return lhs.id == rhs.id
    }
}
