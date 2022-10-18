//
//  CoreDataStack.swift
//  LedGrid
//
//  Created by Ted on 11/08/2022.
//

import Foundation
import CoreData

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
