//
//  IntentHandler.swift
//  Intents
//
//  Created by Ted on 15/08/2022.
//

import Intents

class IntentHandler: INExtension, SelectFriendIntentHandling {
    func handle(intent: SelectFriendIntent) async -> SelectFriendIntentResponse {
        return SelectFriendIntentResponse(code: .success, userActivity: nil)
    }
    
    
    
    func provideFriendOptionsCollection(for intent: SelectFriendIntent) async throws -> INObjectCollection<Friend> {
        let fetch = User.fetchRequest()
        let users = (try? PersistenceManager.shared.viewContext.fetch(fetch)) ?? []
        
        return INObjectCollection(items: users.map { Friend(identifier: $0.id, display: $0.fullName ?? "Unknown")})
    }
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        return self
    }
}
