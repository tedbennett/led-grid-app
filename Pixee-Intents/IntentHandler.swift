//
//  IntentHandler.swift
//  Intents
//
//  Created by Ted on 15/08/2022.
//

import IntentsUI

class IntentHandler: INExtension, SelectFriendIntentHandling, NamedArtIntentHandling {
    
    func handle(intent: SelectFriendIntent) async -> SelectFriendIntentResponse {
        return SelectFriendIntentResponse(code: .success, userActivity: nil)
    }
    
    func handle(intent: NamedArtIntent) async -> NamedArtIntentResponse {
        NSKeyedUnarchiver.setClass(SerializableArt.self, forClassName: "LedGrid.SerializableArt")
        NSKeyedArchiver.setClassName("LedGrid.SerializableArt", for: SerializableArt.self)
        NSKeyedUnarchiver.setClass(SerializableColor.self, forClassName: "LedGrid.SerializableColor")
        NSKeyedArchiver.setClassName("LedGrid.SerializableColor", for: SerializableColor.self)
        return NamedArtIntentResponse(code: .success, userActivity: nil)
    }
    
    
    
    func provideFriendOptionsCollection(for intent: SelectFriendIntent) async throws -> INObjectCollection<Friend> {
        let fetch = User.fetchRequest()
        let users = (try? PersistenceManager.shared.viewContext.fetch(fetch)) ?? []
        
        return INObjectCollection(items: users.map { Friend(identifier: $0.id, display: $0.fullName ?? "Unknown")})
    }
    
    func provideNameOptionsCollection(for intent: NamedArtIntent) async throws -> INObjectCollection<NamedArt> {
        
        NSKeyedUnarchiver.setClass(SerializableArt.self, forClassName: "LedGrid.SerializableArt")
        NSKeyedArchiver.setClassName("LedGrid.SerializableArt", for: SerializableArt.self)
        NSKeyedUnarchiver.setClass(SerializableColor.self, forClassName: "LedGrid.SerializableColor")
        NSKeyedArchiver.setClassName("LedGrid.SerializableColor", for: SerializableColor.self)
        
        let fetch = ArtAssociatedName.fetchRequest()
        let art = (try? PersistenceManager.shared.viewContext.fetch(fetch)) ?? []
        let items = art.compactMap { (item: ArtAssociatedName) -> NamedArt? in
            guard let art = item.art else { return nil }
            let image = item.imageData != nil ? getIntentImage(data: item.imageData!) : nil
            let intent = NamedArt(identifier: art.id, display: item.name, subtitle: nil, image: image)
            return intent
        }
        return INObjectCollection(items: items)
    }
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        return self
    }
    
    func getIntentImage(data: Data) -> INImage? {
        guard let image = UIImage(data: data)?.withRenderingMode(.alwaysOriginal) else {
            return nil
        }
        return INImage(uiImage: image)
    }
}
