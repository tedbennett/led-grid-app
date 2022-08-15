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
        let store = UserDefaults(suiteName: "group.9Y2AMH5S23.com.edwardbennett.pixee")!
        guard let data = store.data(forKey: "friends") else {
            return INObjectCollection<Friend>(items: [])
        }
        let decoded = try JSONDecoder().decode([User].self, from: data)
        
        return INObjectCollection(items: decoded.map { Friend(identifier: $0.id, display: $0.fullName ?? "Unknown")})
    }
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

struct User: Codable, Identifiable {
    var id: String
    var fullName: String?
    var givenName: String?
    var email: String?
}
