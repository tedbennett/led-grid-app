//
//  NamedArtWidget.swift
//  Pixee-WidgetExtension
//
//  Created by Ted Bennett on 07/11/2022.
//

import WidgetKit
import SwiftUI
import Intents

struct NamedArtWidget: Widget {
    let kind: String = "NamedArtWidget"
    
    init() {
        NSKeyedUnarchiver.setClass(SerializableArt.self, forClassName: "LedGrid.SerializableArt")
        NSKeyedArchiver.setClassName("LedGrid.SerializableArt", for: SerializableArt.self)
        NSKeyedUnarchiver.setClass(SerializableColor.self, forClassName: "LedGrid.SerializableColor")
        NSKeyedArchiver.setClassName("LedGrid.SerializableColor", for: SerializableColor.self)
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: NamedArtIntent.self, provider: NamedArtWidgetProvider()) { entry in
            WidgetView(state: entry.state)
        }
        .configurationDisplayName("Pixel Art")
        .description("Pick any art from the app to display")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

