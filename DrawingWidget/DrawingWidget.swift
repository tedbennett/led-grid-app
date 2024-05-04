//
//  DrawingWidget.swift
//  DrawingWidget
//
//  Created by Ted Bennett on 03/05/2024.
//

import SwiftData
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries: [SimpleEntry] = [SimpleEntry(date: .now)]

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct DrawingWidgetEntryView: View {
    @Query(sort: \ReceivedDrawing.createdAt, order: .reverse) var received: [ReceivedDrawing] = []
    var entry: Provider.Entry

    var body: some View {
        if let drawing = received.first {
            ZStack {
                GridView(grid: drawing.grid).padding(0)
                    .blur(radius: drawing.opened ? 0 : 20)
                    .overlay(.black.opacity(!drawing.opened ? 0.4 : 0))
                if !drawing.opened {
                    VStack(spacing: 8) {
                        Image(systemName: "eye")
                            .foregroundStyle(.white)
                        Text("New Drawing Received")
                            .foregroundStyle(.white)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
            }
        } else {
            VStack(spacing: 10) {
                Image(systemName: "square.grid.2x2").rotationEffect(.degrees(45))
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
                Text("No Drawings Received Yet :(")
                    .foregroundStyle(.primary)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
}

struct DrawingWidget: Widget {
    let kind: String = "DrawingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DrawingWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .modelContainer(Container.modelContainer)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DrawingWidget()
} timeline: {
    SimpleEntry(date: .now)
}
