//
//  PixelArt+CoreDataClass.swift
//  LedGrid
//
//  Created by Ted on 11/08/2022.
//
//

import Foundation
import CoreData
import SwiftUI


@objc(StoredPixelArt)
public class StoredPixelArt: NSManagedObject {
    convenience init(from art: PixelArt, context: NSManagedObjectContext) {
        self.init(context: PersistenceManager.shared.viewContext)
        self.id = art.id
        self.hexGrids = art.grids.map { $0.hex() }
        self.title = art.title
        self.sender = art.sender
        self.receivers = art.receivers
        self.sentAt = art.sentAt
        self.opened = art.opened
        self.hidden = art.hidden
    }
}

extension PixelArt {
    init(from art: StoredPixelArt) {
        id = art.id
        title = art.title
        sentAt = art.sentAt
        sender = art.sender
        receivers = art.receivers
        opened = art.opened
        hidden = art.hidden
        grids = PixelArt.parseGrids(from: art.hexGrids)
    }
}
