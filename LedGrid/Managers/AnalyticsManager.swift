//
//  AnalyticsManager.swift
//  LedGrid
//
//  Created by Ted Bennett on 16/11/2022.
//

import Foundation
import Mixpanel
import Sentry

enum AnalyticsEvent: String {
    case signUp = "sign_up"
    case sendArt = "send_art"
    case addFriend = "add_friend"
    case sendReaction = "send_reaction"
    case upgrade = "upgrade_to_plus"
}


struct AnalyticsManager {
    
    static func initialiseSentry() {
        #if !DEBUG
        SentrySDK.start { options in
            options.dsn = "https://e29612af279847dda6037ba43aa31e1a@o1421379.ingest.sentry.io/6769769"
            options.tracesSampleRate = 0.5
        }
        #endif
    }
    
    static func initialiseMixpanel() {
        #if !DEBUG
        Mixpanel.initialize(token: "e2084c8238e48af2dc78abebd84c3f01", trackAutomaticEvents: true)
        #endif
    }
    
    static func trackEvent(_ event: AnalyticsEvent, properties: Properties = [:]) {
        #if !DEBUG
        Mixpanel.mainInstance().track(event: event.rawValue, properties: properties)
        #endif
    }
    
}
