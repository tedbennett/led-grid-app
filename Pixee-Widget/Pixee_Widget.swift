//
//  Pixee_Widget.swift
//  Pixee-Widget
//
//  Created by Ted on 14/08/2022.
//

import WidgetKit
import SwiftUI
import Intents
import Auth0
import SimpleKeychain
import Utilities
struct User: Codable, Identifiable {
    var id: String
    var fullName: String?
    var givenName: String?
    var email: String?
}

struct PixelArt: Codable {
    var grid: [String]
}


struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), colors: [
            [.black, .black, .black, .black, .black, .black, .black, .black],
            [.black, .black, .white, .black, .black, .white, .black, .black],
            [.black, .black, .white, .black, .black, .white, .black, .black],
            [.black, .black, .black, .black, .black, .black, .black, .black],
            [.black, .black, .black, .black, .black, .black, .black, .black],
            [.black, .white, .black, .black, .black, .black, .white, .black],
            [.black, .white, .white, .white, .white, .white, .white, .black],
            [.black, .black, .black, .black, .black, .black, .black, .black]
        ], configuration: SelectFriendIntent())
    }
    
    func getSnapshot(for configuration: SelectFriendIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), colors: [
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
              let userId = try?  JSONDecoder().decode(User.self, from: data) else {
            // Failure
            completion(.failure(.notLoggedIn))
            return
        }
        let credentialManager = CredentialsManager(authentication: Auth0.authentication(), storage: SimpleKeychain(service: "Pixee", accessGroup: "9Y2AMH5S23.com.edwardbennett.LedGrid"))
        
        credentialManager.credentials { res in
            switch res {
            case .success(let credentials):
                let headers = ["Authorization": "Bearer \(credentials.idToken)"]
                makeRequest(userId: userId.id, queries: queries, headers: headers) { result in
                    completion(result)
                }
            case .failure(_):
                // Failed to find credentials
                completion(.failure(.notLoggedIn))
                break
            }
        }
        
    }
    
    func getTimeline(for configuration: SelectFriendIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let sender = configuration.friend?.identifier
        getLastReceivedGrid(from: sender) { result in
            
            switch result {
            case .success(let art):
                let colors = parseGrids(from: art.grid)
                entries.append(SimpleEntry(date: Date(), colors: colors.first, configuration: configuration))
            case .failure(let error):
                entries.append(SimpleEntry(date: Date(), text: error.errorText, configuration: configuration))
            }
            
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }
        
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    var text: String?
    var colors: [[Color]]?
    let configuration: SelectFriendIntent
}

struct Pixee_WidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        if let text = entry.text {
            Text(text).foregroundColor(.gray).font(.callout)
        } else {
            let colors = entry.colors!
            MiniGridView(grid: colors).padding(10)
            
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
        .configurationDisplayName("Pixee")
        .description("The most recent pixel art you have received")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

struct Pixee_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Pixee_WidgetEntryView(entry: SimpleEntry(date: Date(), text: "Hi", configuration: SelectFriendIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}



func makeRequest(userId: String, queries: [String: String],  headers: [String:String] = [:], completion: @escaping (Result<PixelArt, WidgetError>) -> Void) {
    var components = URLComponents(string: "https://rlefhg7mpa.execute-api.us-east-1.amazonaws.com/user/\(userId)/grid/last")!
    
    components.queryItems = queries.map { key, value in
        URLQueryItem(name: key, value: value)
    }
    var urlRequest = URLRequest(url: components.url!)
    headers.forEach {key, value in
        urlRequest.addValue(value, forHTTPHeaderField: key)
    }
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
        if let error = error {
            print(error.localizedDescription)
            completion(.failure(.networkError))
            return
        }
        guard let data = data else {
            completion(.failure(.networkError))
            return
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        if let received = try? decoder.decode([PixelArt].self, from: data) {
            if let art = received.first {
                completion(.success(art))
            } else {
                completion(.failure(.noneFound))
            }
        } else {
            completion(.failure(.networkError))
        }
    }.resume()
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

func parseGrids(from strings: [String]) -> [[[Color]]] {
    return strings.map { string in
        let components = string.components(withMaxLength: 6).map { Color(hexString: $0) }
        let size = Int(Double(components.count).squareRoot())
        return (0..<size).map {
            let index = $0 * size
            return Array(components[index..<(index + size)])
        }
    }
}
extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    init(hexString: String) {
        let parsed = Int(hexString.suffix(6), radix: 16) ?? 0
        self.init(hex: parsed)
    }
    var hex: String {
        let uiColor = UIColor(self)
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"%06x", rgb)
    }
}
extension String {
    func components(withMaxLength length: Int) -> [String] {
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}

enum GridSize: Int, Codable {
    case small = 8
    case medium = 12
    case large = 16
    
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


struct MiniGridView: View {
    var grid: [[Color]]
    
    var strokeWidth: Double { 0
//        switch gridSize {
//        case .small: return 0.4
//        case .medium: return 0.3
//        case .large: return 0.2
//        }
    }
    
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
struct SquareView: View {
    var color: Color
    var strokeWidth = 2.0
    var cornerRadius = 3.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(color)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(UIColor.gray), lineWidth: strokeWidth)
                
            )
            .aspectRatio(contentMode: .fit)
    }
}
