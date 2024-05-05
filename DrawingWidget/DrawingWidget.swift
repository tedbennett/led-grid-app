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
    func placeholder(in context: Context) -> DrawingEntry {
        DrawingEntry(drawing: Grid.smiley, opened: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (DrawingEntry) -> ()) {
        let entry = DrawingEntry(drawing: Grid.smiley, opened: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let drawing = await Container().getLatestReceivedDrawing()
            let entries = [DrawingEntry(drawing: drawing?.grid, opened: drawing?.opened ?? true)]
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct DrawingEntry: TimelineEntry {
    let date: Date = .now
    let drawing: Grid?
    let opened: Bool
}

struct DrawingWidgetEntryView: View {
    @Query(sort: \ReceivedDrawing.createdAt, order: .reverse) var received: [ReceivedDrawing] = []
    var entry: Provider.Entry

    var body: some View {
        if let drawing = entry.drawing {
            ZStack {
                GridView(grid: drawing).padding(0)
                    .blur(radius: entry.opened ? 0 : 20)
                    .overlay(.black.opacity(!entry.opened ? 0.4 : 0))
                    .aspectRatio(contentMode: .fit)
                if !entry.opened {
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
        .configurationDisplayName("Latest Drawing Widget")
        .description("Your most recently received drawing.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DrawingWidget()
} timeline: {
    DrawingEntry(drawing: nil, opened: false)
}
