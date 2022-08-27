//
//  Pixee_Widget.swift
//  Pixee-Widget
//
//  Created by Ted on 14/08/2022.
//

import WidgetKit
import SwiftUI
import Intents
import SimpleKeychain
import Utilities


struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> PixeeEntry {
        PixeeEntry(date: Date(), text: "Loading...", configuration: SelectFriendIntent())
    }
    
    func getSnapshot(for configuration: SelectFriendIntent, in context: Context, completion: @escaping (PixeeEntry) -> ()) {
        if !context.isPreview {
            completion(PixeeEntry(date: Date(), text: "Loading...", configuration: SelectFriendIntent()))
            return
        }
        let entry = PixeeEntry(date: Date(), colors: [
            [.black, .black, .black, .black, .black, .black, .black, .black],
            [.black, .black, .white, .black, .black, .white, .black, .black],
            [.black, .black, .white, .black, .black, .white, .black, .black],
            [.black, .black, .black, .black, .black, .black, .black, .black],
            [.black, .black, .black, .black, .black, .black, .black, .black],
            [.black, .white, .black, .black, .black, .black, .white, .black],
            [.black, .white, .white, .white, .white, .white, .white, .black],
            [.black, .black, .black, .black, .black, .black, .black, .black]
        ], configuration: configuration)
        completion(entry)
    }
    
    func getLastReceivedGrid(from sender: String? = nil, completion: @escaping(Result<PixelArt, WidgetError>) -> Void) {
        let queries: [String: String] = sender != nil ? ["sender": sender!] : [:]
        
        let store = UserDefaults(suiteName: "group.9Y2AMH5S23.com.edwardbennett.pixee")!
        guard let data = store.data(forKey: "user"),
              let user = try?  JSONDecoder().decode(User.self, from: data) else {
            // Failure
            completion(.failure(.notLoggedIn))
            return
        }
        Task {
            do {
                let headers = try await AuthService.getToken()
                let url = Network.makeUrl([.art, .users, .dynamic(user.id), .received, .last], queries: queries)
                print(url.absoluteString)
                let res = try await Network.makeRequest(url: url, body: nil, headers: headers)
                guard let art = try? JSONDecoder.standard.decode(PixelArt.self, from: res) else {
                    completion(.failure(.noneFound))
                    return
                }
                
                completion(.success(art))
            } catch is NetworkError {
                completion(.failure(.networkError))
            } catch {
                completion(.failure(.notLoggedIn))
            }
        }
    }
    
    func getTimeline(for configuration: SelectFriendIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [PixeeEntry] = []
        let sender = configuration.friend?.identifier
        getLastReceivedGrid(from: sender) { result in
            
            switch result {
            case .success(let art):
                entries.append(PixeeEntry(date: Date(), colors: art.grids.first, configuration: configuration))
            case .failure(let error):
                entries.append(PixeeEntry(date: Date(), text: error.errorText, configuration: configuration))
            }
            
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }
        
    }
}

struct PixeeEntry: TimelineEntry {
    var date: Date
    var text: String?
    var colors: Grid?
    let configuration: SelectFriendIntent
}

struct Pixee_WidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        if let text = entry.text {
            VStack {
                Image(systemName: "square.grid.2x2")
                    .foregroundColor(.gray)
                    .font(.title3)
                    .rotationEffect(.degrees(45))
                    .padding(5)
                Text(text).foregroundColor(.gray).font(.callout)
            }.unredacted()
        } else {
            let colors = entry.colors!
            WidgetGridView(grid: colors).padding(10)
                .widgetURL(URL(string: "widget://received")!)
            
        }
        
    }
}

@main
struct Pixee_Widget: Widget {
    let kind: String = "Pixee_Widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectFriendIntent.self, provider: Provider()) { entry in
            Pixee_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Pixel Art")
        .description("The most recently received pixel art from a friend")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

struct Pixee_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Pixee_WidgetEntryView(entry: PixeeEntry(date: Date(), text: "Hi", configuration: SelectFriendIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}



enum WidgetError: Error {
    case notLoggedIn
    case networkError
    case noneFound
    
    var errorText: String {
        switch self {
        case .notLoggedIn:
            return "Login to Pixee to receive art!"
        case .networkError:
            return "Failed to fetch art"
        case .noneFound:
            return "Add some friends to receive art!"
        }
    }
}


struct PixelArtGrid<Content: View>: View {
    let content: (Int, Int) -> Content
    let gridSize: GridSize
    let _spacing: Double?
    
    init(gridSize: GridSize, spacing: Double? = nil, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.content = content
        self.gridSize = gridSize
        self._spacing = spacing
    }
    
    var spacing: Double {
        if let spacing = _spacing { return spacing }
        switch gridSize {
        case .small:
            return 6
        case .medium:
            return 4
        case .large:
            return 2
        }
    }
    
    var body: some View {
        switch gridSize {
        case .small:
            VStack(spacing: spacing) {
                ForEach(0..<8) { col in
                    HStack(spacing: spacing) {
                        ForEach(0..<8) { row in
                            content(col, row)
                        }
                    }
                }
            }
        case .medium:
            VStack(spacing: spacing) {
                ForEach(0..<12) { col in
                    HStack(spacing: spacing) {
                        ForEach(0..<12) { row in
                            content(col, row)
                        }
                    }
                }
            }
        case .large:
            VStack(spacing: spacing) {
                ForEach(0..<16) { col in
                    HStack(spacing: spacing) {
                        ForEach(0..<16) { row in
                            content(col, row)
                        }
                    }
                }
            }
        }
    }
    
}


struct WidgetGridView: View {
    var grid: Grid
    
    var strokeWidth: Double = 0
    
    var cornerRadius: Double {
        switch gridSize {
        case .small: return 3.0
        case .medium: return 2.5
        case .large: return 2.0
        }
    }
    
    var spacing: Double {
        switch gridSize {
        case .small: return 3
        case .medium: return 2
        case .large: return 1.5
        }
    }
    
    var gridSize: GridSize {
        GridSize(rawValue: grid.count) ?? .small
    }
    
    var body: some View {
        PixelArtGrid(gridSize: gridSize, spacing: spacing) { col, row in
            let color = grid[col][row]
            SquareView(color: color, strokeWidth: strokeWidth, cornerRadius: cornerRadius)
        }
    }
}
