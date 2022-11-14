//
//  FriendWidget.swift
//  Pixee-WidgetExtension
//
//  Created by Ted Bennett on 07/11/2022.
//

import WidgetKit
import SwiftUI
import Intents

struct FriendWidget: Widget {
    let kind: String = "FriendWidget"
    
    init() {
        NSKeyedUnarchiver.setClass(SerializableArt.self, forClassName: "LedGrid.SerializableArt")
        NSKeyedArchiver.setClassName("LedGrid.SerializableArt", for: SerializableArt.self)
        NSKeyedUnarchiver.setClass(SerializableColor.self, forClassName: "LedGrid.SerializableColor")
        NSKeyedArchiver.setClassName("LedGrid.SerializableColor", for: SerializableColor.self)
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectFriendIntent.self, provider: FriendWidgetProvider()) { entry in
            WidgetView(state: entry.state)
        }
        .configurationDisplayName("Art From Friends")
        .description("The most recently received pixel art from a friend")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}


struct Pixee_Widget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(state: .error(text: "When you receive art from this user, it will appear here"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}


