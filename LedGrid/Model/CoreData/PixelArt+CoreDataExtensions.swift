//
//  PixelArt+CoreDataExtensions.swift
//  LedGrid
//
//  Created by Ted Bennett on 18/10/2022.
//

import Foundation
import CoreData
import UIKit

extension PixelArt {
    convenience init(from art: MPixelArt, users: [User], context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = art.id
        self.title = art.title
        self.sender = art.sender
        self.sentAt = art.sentAt
        self.opened = art.opened
        self.hidden = art.hidden
        let colors = art.grids.map { grid in
            grid.map { row in
                row.map {
                    SerializableColor(from: UIColor($0))
                }
            }
        }
        self.art = SerializableArt(grids: colors)
        self.users = NSSet(array: users)
    }
    
    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: User)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: User)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)
    
    @objc(addReactionsObject:)
    @NSManaged public func addToReactions(_ value: Reaction)

    @objc(removeReactionsObject:)
    @NSManaged public func removeFromReactions(_ value: Reaction)

    @objc(addReactions:)
    @NSManaged public func addToReactions(_ values: NSSet)

    @objc(removeReactions:)
    @NSManaged public func removeFromReactions(_ values: NSSet)
    
    
    var gridSize: GridSize {
        let size = art.grids.first?.count ?? 8
        return GridSize(rawValue: size) ?? .small
    }
    
    static func dictionaryValue(from art: MPixelArt) -> [String: Any] {
        [
            "id": art.id,
            "title": art.title as Any,
            "sentAt": art.sentAt,
            "sender": art.sender,
            "opened": art.opened,
            "hidden": art.hidden,
            "art": SerializableArt(grids: art.grids)
        ]
    }
}

extension PixelArt : Identifiable {

}
