//
//  PixelArt+CoreDataProperties.swift
//  LedGrid
//
//  Created by Ted on 11/08/2022.
//
//

import Foundation
import CoreData


extension PixelArt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PixelArt> {
        return NSFetchRequest<PixelArt>(entityName: "PixelArt")
    }

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var sentAt: Date
    @NSManaged public var sender: String
    @NSManaged public var receivers: [String]
    @NSManaged public var opened: Bool
    @NSManaged public var hidden: Bool
    @NSManaged public var hexGrids: [String]
    
    var size: GridSize {
        grids[0].size
    }
    
    var grids: [Grid] {
        get {
            parseGrids(from: hexGrids)
        } set {
            hexGrids = newValue.map { $0.hex() }
        }
    }

}

extension PixelArt : Identifiable {

}

extension PixelArt: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(grids, forKey: .grid)
        try container.encode(GridSize(rawValue: self.grids[0].count), forKey: .gridSize)
        try container.encode(title, forKey: .title)
        try container.encode(sentAt, forKey: .sentAt)
        try container.encode(id, forKey: .id)
        try container.encode(opened, forKey: .opened)
        try container.encode(sender, forKey: .sender)
        try container.encode(receivers, forKey: .receivers)
        try container.encode(hidden, forKey: .hidden)
    }
}
