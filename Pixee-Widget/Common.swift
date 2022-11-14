//
//  Common.swift
//  Pixee-WidgetExtension
//
//  Created by Ted Bennett on 07/11/2022.
//

import WidgetKit
import SwiftUI
import Intents


let SMILEY_WIDGET: [Grid] = [[
    [.black, .black, .black, .black, .black, .black, .black, .black],
    [.black, .black, .white, .black, .black, .white, .black, .black],
    [.black, .black, .white, .black, .black, .white, .black, .black],
    [.black, .black, .black, .black, .black, .black, .black, .black],
    [.black, .black, .black, .black, .black, .black, .black, .black],
    [.black, .white, .black, .black, .black, .black, .white, .black],
    [.black, .white, .white, .white, .white, .white, .white, .black],
    [.black, .black, .black, .black, .black, .black, .black, .black]
]]

struct WidgetView : View {
    var state: EntryState
    
    func url(sender: String?, id: String?) -> URL {
        if let sender = sender, let id = id {
            return URL(string: "widget://received/\(sender)/id/\(id)")!
        }
        return URL(string: "widget://received")!
    }
    
    var body: some View {
        VStack {
            switch state {
            case .art(let grids, let sender, let id):
                WidgetGridView(grid: grids.first!).padding(10)
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

enum EntryState {
    case art(grids: [Grid], sender: String?, id: String)
    case error(text: String)
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
