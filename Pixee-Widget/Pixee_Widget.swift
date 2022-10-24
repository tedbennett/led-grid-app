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


struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> PixeeEntry {
        PixeeEntry(date: Date(), state: .error(text: "Loading"), configuration: SelectFriendIntent())
    }
    
    func getSnapshot(for configuration: SelectFriendIntent, in context: Context, completion: @escaping (PixeeEntry) -> ()) {
        if !context.isPreview {
            completion(PixeeEntry(date: Date(), state: .error(text: "Loading"), configuration: SelectFriendIntent()))
            return
        }
        let entry = PixeeEntry(date: Date(), state: .art(grid: [
            [.black, .black, .black, .black, .black, .black, .black, .black],
            [.black, .black, .white, .black, .black, .white, .black, .black],
            [.black, .black, .white, .black, .black, .white, .black, .black],
            [.black, .black, .black, .black, .black, .black, .black, .black],
            [.black, .black, .black, .black, .black, .black, .black, .black],
            [.black, .white, .black, .black, .black, .black, .white, .black],
            [.black, .white, .white, .white, .white, .white, .white, .black],
            [.black, .black, .black, .black, .black, .black, .black, .black]
        ], sender: nil, id: ""), configuration: configuration)
        completion(entry)
    }
    
    func getLastReceivedGrid(from sender: String? = nil, completion: @escaping(Result<MPixelArt, WidgetError>) -> Void) {
        let queries: [String: String] = sender != nil ? ["sender": sender!] : [:]
        
        let store = UserDefaults(suiteName: "group.9Y2AMH5S23.com.edwardbennett.pixee")!
        guard let data = store.data(forKey: "user"),
              let user = try?  JSONDecoder().decode(MUser.self, from: data) else {
            // Failure
            completion(.failure(.notLoggedIn))
            return
        }
        Task {
            do {
                let headers = try await AuthService.getToken()
                let url = Network.makeUrl([.art, .users, .dynamic(user.id), .received, .last], queries: queries)
                let res = try await Network.makeRequest(url: url, body: nil, headers: headers)
                guard let art = try? JSONDecoder.standard.decode(MPixelArt.self, from: res) else {
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
    
    func getGridById(_ id: String, completion: @escaping(Result<MPixelArt, WidgetError>) -> Void) {
        Task {
            do {
                let headers = try await AuthService.getToken()
                let url = Network.makeUrl([.art, .dynamic(id)])
                let res = try await Network.makeRequest(url: url, body: nil, headers: headers)
                guard let art = try? JSONDecoder.standard.decode(MPixelArt.self, from: res) else {
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
    
    func getGridFromCoreData(from sender: String?, configuration: SelectFriendIntent) -> PixeeEntry {
        let fetch = PixelArt.fetchRequest()
        if let sender = sender {
            fetch.predicate = NSPredicate(format: "ANY users.id == %@", sender)
        }
        fetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(PixelArt.sentAt), ascending: false)]
        fetch.fetchLimit = 1
        let art = try? PersistenceManager.shared.viewContext.fetch(fetch)
        
        if let art = art?.first {
            let grid = art.art.toColors().first!
            let state = EntryState.art(grid: grid, sender: sender, id: art.id)
            return PixeeEntry(date: Date(), state: state, configuration: configuration)
        } else {
            return PixeeEntry(date: Date(), state: .error(text: "Add some friends to receive art!"), configuration: configuration)
        }
    }
    
    func getTimeline(for configuration: SelectFriendIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [PixeeEntry] = []
        let sender = configuration.friend?.identifier
        getLastReceivedGrid(from: sender) { result in
            
            switch result {
            case .success(let art):
                let state: EntryState = .art(grid: art.grids.first!, sender: art.sender, id: art.id)
                entries.append(PixeeEntry(date: Date(), state: state, configuration: configuration))
            case .failure(let error):
                entries.append(PixeeEntry(date: Date(), state: .error(text: error.errorText), configuration: configuration))
            }
            
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }
    }
}

enum EntryState {
    case art(grid: Grid, sender: String?, id: String)
    case error(text: String)
}

struct PixeeEntry: TimelineEntry {
    var date: Date
    var state: EntryState
    let configuration: SelectFriendIntent
}

struct Pixee_WidgetEntryView : View {
    var entry: Provider.Entry
    
    func url(sender: String?, id: String?) -> URL {
        if let sender = sender, let id = id {
            return URL(string: "widget://received/\(sender)/id/\(id)")!
        }
        return URL(string: "widget://received")!
    }
    
    var body: some View {
        VStack {
            switch entry.state {
            case .art(let grid, let sender, let id):
                WidgetGridView(grid: grid).padding(10)
                    .widgetURL(url(sender: sender, id: id))
            case .error(let text):
                VStack {
                    Image(systemName: "square.grid.2x2")
                        .foregroundColor(.gray)
                        .font(.title3)
                        .rotationEffect(.degrees(45))
                        .padding(5)
                    Text(text).foregroundColor(.gray).multilineTextAlignment(.center).font(.callout).padding(.horizontal, 10)
                }.unredacted()
            }
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
        Pixee_WidgetEntryView(entry: PixeeEntry(date: Date(), state: .error(text: "Hi"), configuration: SelectFriendIntent()))
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
