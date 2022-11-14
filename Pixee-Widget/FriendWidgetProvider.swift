//
//  FriendWidgetProvider.swift
//  Pixee-WidgetExtension
//
//  Created by Ted Bennett on 07/11/2022.
//

import WidgetKit

struct PixeeFriendEntry: TimelineEntry {
    var date: Date
    var state: EntryState
    let configuration: SelectFriendIntent
}

struct FriendWidgetProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> PixeeFriendEntry {
        PixeeFriendEntry(date: Date(), state: .error(text: "Loading"), configuration: SelectFriendIntent())
    }
    
    func getSnapshot(for configuration: SelectFriendIntent, in context: Context, completion: @escaping (PixeeFriendEntry) -> ()) {
        if !context.isPreview {
            completion(PixeeFriendEntry(date: Date(), state: .error(text: "Loading"), configuration: SelectFriendIntent()))
            return
        }
        let entry = PixeeFriendEntry(date: Date(), state: .art(grids: SMILEY_WIDGET, sender: nil, id: ""), configuration: configuration)
        completion(entry)
    }
    
    func getGrid(from sender: String?, configuration: SelectFriendIntent) -> PixeeFriendEntry {
        let fetch = PixelArt.fetchRequest()
        if let sender = sender {
            fetch.predicate = NSPredicate(format: "sender == %@", sender)
        }
        fetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(PixelArt.sentAt), ascending: false)]
        fetch.fetchLimit = 1
        let art = try? PersistenceManager.shared.viewContext.fetch(fetch)
        
        if let art = art?.first {
            let grids = art.art.toColors()
            let state = EntryState.art(grids: grids, sender: sender, id: art.id)
            return PixeeFriendEntry(date: Date(), state: state, configuration: configuration)
        } else if sender != nil {
            return PixeeFriendEntry(date: Date(), state: .error(text: "When you receive art from this friend, it will appear here"), configuration: configuration)
        } else {
            return PixeeFriendEntry(date: Date(), state: .error(text: "Add some friends to receive art!"), configuration: configuration)
        }
    }
    
    func getTimeline(for configuration: SelectFriendIntent, in context: Context, completion: @escaping (Timeline<PixeeFriendEntry>) -> ()) {
        let sender = configuration.friend?.identifier
        let art = getGrid(from: sender, configuration: configuration)
        completion(Timeline(entries: [art], policy: .never))
    }
    
}
