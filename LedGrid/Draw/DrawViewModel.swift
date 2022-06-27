//
//  DrawViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

class DrawViewModel: ObservableObject {
    @Published var grid: [[Color]] = Utility.lastGrid
    @Published var currentColor: Color = .blue
    @Published var message: String = ""
    
    func shouldSetGridSquare(row: Int, col: Int) -> Bool {
        return grid[col][row] != currentColor
    }
    
    func setGridSquare(row: Int, col: Int) {
        grid[col][row] = currentColor
    }
    
    func saveGrid() {
        Utility.lastGrid = grid
    }
    
    private func flattenGrid(_ grid: [[Color]]) -> String {
        return grid.flatMap { row in row.map { $0.hex }}.joined(separator: "")
    }
    
    func sendGrid() {
        if var sentGrid = Utility.sentGrids.first(where: { flattenGrid($0.grid) == flattenGrid(grid) }) {
            sentGrid.updateDate()
            Utility.sentGrids.removeAll(where: { $0.id == sentGrid.id })
            Utility.sentGrids.insert(sentGrid, at: 0)
            PeripheralManager.shared.sendToDevice(colors: sentGrid.toHex())
        } else {
            let colorGrid = ColorGrid(name: message, id: UUID().uuidString, grid: grid)
            Utility.sentGrids.insert(colorGrid, at: 0)
            PeripheralManager.shared.sendToDevice(colors: colorGrid.toHex())
        }
    }
    
    func clearGrid() {
        grid = Array(repeating: Array(repeating: Color.black, count: 8), count: 8)
        saveGrid()
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    var hex: String {
        let uiColor = UIColor(self)
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}
