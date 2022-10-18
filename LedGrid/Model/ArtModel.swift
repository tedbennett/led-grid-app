////
////  ArtModel.swift
////  LedGrid
////
////  Created by Ted Bennett on 03/10/2022.
////
//
//import Foundation
//import CoreData
//import Sentry
//
//protocol ArtModelProtocol {
////    func fetchArt(for user: String) async -> [PixelArt]
//    func fetchLocalReceivedArt() -> [PixelArt]
//    func fetchLocalSentArt() -> [PixelArt]
//    func insertSentArt(_ art: PixelArt) async -> Void
//    func fetchReceivedArt(since: Date?) async -> [PixelArt]
//    func hideArt(id: String)
//    func openArt(id: String, opened: Bool)
//    func removeAllArt()
//}
//
//
//struct ArtModel: ArtModelProtocol {
//
//    func importArt() async {
//
//    }
//
//    func fetchArt() async -> [PixelArt] {
//        let receivedFetch = StoredPixelArt.fetchRequest()
//        receivedFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPixelArt.sentAt), ascending: false)]
//        let fetched = await PersistenceManager.shared.container.performBackgroundTask { context in
//            let art = (try? context.fetch(receivedFetch)) ?? []
//            return art.map {PixelArt(from: $0) }
//        }
//        return fetched
//    }
//
//    func fetchArt(for user: String) async -> [PixelArt] {
//        let receivedFetch = StoredPixelArt.fetchRequest()
//        let predicate = {
//            let sender = NSPredicate(format: "sender = %@", user)
//            let receivers = NSPredicate(format: "ANY receivers = %@", [user])
//            let compound = NSCompoundPredicate(orPredicateWithSubpredicates: [sender, receivers])
//            return NSCompoundPredicate(andPredicateWithSubpredicates: [
//                compound,
//                NSPredicate(format: "hidden != true")
//            ])
//        }()
//        receivedFetch.predicate = predicate
//        receivedFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPixelArt.sentAt), ascending: false)]
//        let fetched = await PersistenceManager.shared.container.performBackgroundTask { context in
//            let art = (try? context.fetch(receivedFetch)) ?? []
//
//            return art.map {PixelArt(from: $0) }
//        }
//        return fetched
//    }
//
//    func fetchLocalReceivedArt() -> [PixelArt] {
//        guard let user = Utility.user?.id else { return [] }
//        let receivedFetch = StoredPixelArt.fetchRequest()
//        receivedFetch.predicate = NSPredicate(format: "sender != %@ AND hidden != true", user)
//        receivedFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPixelArt.sentAt), ascending: false)]
//        let fetched = (try? PersistenceManager.shared.viewContext.fetch(receivedFetch)) ?? []
//        return fetched.map { PixelArt(from: $0) }
//    }
//
//    func fetchLocalSentArt() -> [PixelArt] {
//        guard let user = Utility.user?.id else { return [] }
//        let sentFetch = StoredPixelArt.fetchRequest()
//        sentFetch.predicate = NSPredicate(format: "sender = %@ AND hidden != true", user)
//        sentFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPixelArt.sentAt), ascending: false)]
//        let fetched = (try? PersistenceManager.shared.viewContext.fetch(sentFetch)) ?? []
//        return fetched.map { PixelArt(from: $0) }
//    }
//
//    func insertSentArt(_ art: PixelArt) async {
//        await MainActor.run {
//            let _ = StoredPixelArt(from: art, context: PersistenceManager.shared.viewContext)
//            PersistenceManager.shared.save()
//        }
//    }
//
//    func fetchAllArt() async {
//        do {
//            var received = try await NetworkManager.shared.getGrids(after: nil)
//            let sent = try await NetworkManager.shared.getSentGrids(after: nil)
//
//            received = received.map {
//                var grid = $0
//                grid.opened = true
//                return grid
//            }
//            try await MainActor.run { [received, sent] in
//                let _ = received.map { StoredPixelArt(from: $0, context: PersistenceManager.shared.viewContext) }
//                let _ = sent.map { StoredPixelArt(from: $0, context: PersistenceManager.shared.viewContext) }
//                try PersistenceManager.shared.viewContext.save()
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    func fetchReceivedArt(since: Date?) async -> [PixelArt] {
//        do {
//            let grids = try await NetworkManager.shared.getGrids(after: since)
//            let unopened = grids.map {
//                var grid = $0
//                grid.opened = false
//                return grid
//            }
//            if !unopened.isEmpty {
//                let _ = unopened.map { StoredPixelArt(from: $0, context: PersistenceManager.shared.viewContext) }
//                try PersistenceManager.shared.viewContext.save()
//
//            }
//            return unopened
//        } catch {
//            print(error.localizedDescription)
//        }
//        return []
//    }
//
//    //    func fetchAllSentArt() async -> [PixelArt] {
//    //        do {
//    //            let grids = try await NetworkManager.shared.getSentGrids(after: nil)
//    //            await MainActor.run {
//    //                if !grids.isEmpty {
//    //                    let _ = grids.map { StoredPixelArt(from: $0, context: PersistenceManager.shared.viewContext) }
//    //                    PersistenceManager.shared.save()
//    //                }
//    //            }
//    //            return grids
//    //        } catch {
//    //            print(error.localizedDescription)
//    //        }
//    //        return []
//    //    }
//
//    func hideArt(id: String) {
//        let fetch = StoredPixelArt.fetchRequest()
//        fetch.predicate = NSPredicate(format: "id = %@", id)
//        fetch.fetchLimit = 1
//        guard let grid = (try? PersistenceManager.shared.viewContext.fetch(fetch))?.first else { return }
//        grid.hidden.toggle()
//        try? PersistenceManager.shared.viewContext.save()
//    }
//
//    func openArt(id: String, opened: Bool) {
//        let fetch = StoredPixelArt.fetchRequest()
//        fetch.predicate = NSPredicate(format: "id = %@", id)
//        fetch.fetchLimit = 1
//        guard let grid = (try? PersistenceManager.shared.viewContext.fetch(fetch))?.first else { return }
//        grid.opened = opened
//        try? PersistenceManager.shared.viewContext.save()
//    }
//
//    func removeAllArt() {
//        let fetch: NSFetchRequest<NSFetchRequestResult> = StoredPixelArt.fetchRequest()
//        let deleteRequest = NSBatchDeleteRequest(
//            fetchRequest: fetch
//        )
//        _ = try? PersistenceManager.shared.viewContext.execute(deleteRequest)
//        PersistenceManager.shared.save()
//    }
//}
