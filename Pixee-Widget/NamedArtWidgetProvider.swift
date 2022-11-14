//
//  NamedArtWidgetProvider.swift
//  Pixee-WidgetExtension
//
//  Created by Ted Bennett on 07/11/2022.
//

import WidgetKit

struct PixeeNamedEntry: TimelineEntry {
    var date: Date
    var state: EntryState
    let configuration: NamedArtIntent
}

struct NamedArtWidgetProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> PixeeNamedEntry {
        PixeeNamedEntry(date: Date(), state: .error(text: "Loading..."), configuration: NamedArtIntent())
    }
    
    func getSnapshot(for configuration: NamedArtIntent, in context: Context, completion: @escaping (PixeeNamedEntry) -> ()) {
        if !context.isPreview {
            completion(PixeeNamedEntry(date: Date(), state: .error(text: "Loading..."), configuration: NamedArtIntent()))
            return
        }
        let entry = PixeeNamedEntry(date: Date(), state: .art(grids: SMILEY_WIDGET, sender: nil, id: ""), configuration: configuration)
        completion(entry)
    }
    
    func fetchArt(id: String?) -> PixelArt? {
        if let id = id {
            let fetch = PixelArt.fetchRequest()
            fetch.predicate = NSPredicate(format: "id = %@", id)
            fetch.fetchLimit = 1
            let art = try! PersistenceManager.shared.viewContext.fetch(fetch)
            
            return art.first
        } else {
            let fetch = PixelArt.fetchRequest()
            let count = try! PersistenceManager.shared.viewContext.count(for: fetch)
            
            fetch.fetchOffset = Int.random(in: 0...count)
            fetch.fetchLimit = 1
            let art = try! PersistenceManager.shared.viewContext.fetch(fetch)
            
            return art.first
        }
    }
    
    func getGrid(id: String?, configuration: NamedArtIntent) -> PixeeNamedEntry {
        guard let art = fetchArt(id: id) else {
            return PixeeNamedEntry(date: Date(), state: .error(text: "Failed to find art"), configuration: configuration)
        }
        
        let sender = art.sender == Utility.user?.id ? art.userArray.first?.id : art.sender
        let grids = art.art.toColors()
        let state = EntryState.art(grids: grids, sender: sender, id: art.id)
        return PixeeNamedEntry(date: Date(), state: state, configuration: configuration)
    }
    
    func getTimeline(for configuration: NamedArtIntent, in context: Context, completion: @escaping (Timeline<PixeeNamedEntry>) -> ()) {
        let random = configuration.random?.boolValue ?? false
        let id = random || !Utility.isPlus ? nil : configuration.name?.identifier
        let art = getGrid(id: id, configuration: configuration)
        completion(Timeline(entries: [art], policy: .never))
    }
}
