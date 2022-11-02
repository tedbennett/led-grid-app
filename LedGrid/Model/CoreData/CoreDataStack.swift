//
//  CoreDataStack.swift
//  LedGrid
//
//  Created by Ted on 11/08/2022.
//

import Foundation
import CoreData
import SwiftUI

struct PersistenceManager {
    // A singleton for our entire app to use
    static let shared = PersistenceManager()

    // Storage for Core Data
    let container: NSPersistentContainer

    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    private init(inMemory: Bool = false) {
        // If you didn't name your model Main you'll need
        // to change this name below.
        
        ValueTransformer.setValueTransformer(
            SerializableArtTransformer(),
              forName: NSValueTransformerName(rawValue: "SerializableArtTransformer")
        )
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.9Y2AMH5S23.com.edwardbennett.pixee")!
        let storeURL = containerURL.appendingPathComponent("Pixee.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        container = NSPersistentContainer(name: "Pixee")
        container.persistentStoreDescriptions = [description]
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
                print(error.localizedDescription)
            }
        }
    }
}

struct MockPersistenceController {
    // A singleton for our entire app to use
    static let shared = MockPersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer

    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    private init() {
        // If you didn't name your model Main you'll need
        // to change this name below.
        
        ValueTransformer.setValueTransformer(
            SerializableArtTransformer(),
              forName: NSValueTransformerName(rawValue: "SerializableArtTransformer")
        )
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.9Y2AMH5S23.com.edwardbennett.pixee")!
        let storeURL = containerURL.appendingPathComponent("Pixee.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        container = NSPersistentContainer(name: "Pixee")
        container.persistentStoreDescriptions = [description]
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        DispatchQueue.main.async { [self] in
            let user = User(context: viewContext)
            user.fullName = "Ted Bennett"
            user.id = UUID().uuidString
            user.email = "ted@email.com"
            user.givenName = "Ted"
            
            let art = PixelArt(context: viewContext)
            art.art = SerializableArt(grids: [Array(repeating: Array(repeating: Color.red, count: 8), count: 8)])
            art.id = UUID().uuidString
            art.hidden = false
            art.opened = true
            art.sender = user.id
            art.sentAt = Date()
            art.users = [user]
            
            save()
        }
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
                print(error.localizedDescription)
            }
        }
    }
}
