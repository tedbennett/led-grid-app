//
//  Utility.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

struct Utility {
    static var lastGrid: [[Color]] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "lastGrid"),
                  let colors = try? JSONDecoder().decode([[Color]].self, from: data) else {
                return Array(repeating: Array(repeating: Color.black, count: 8), count: 8)
            }
            return colors
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            DispatchQueue.main.async {
                UserDefaults.standard.set(data, forKey: "lastGrid")
            }
        }
    }
    
    static var receivedGrids: [ColorGrid] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "receivedGrids"),
                  let grids = try? JSONDecoder().decode([ColorGrid].self, from: data) else {
                return []
            }
            return grids
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            DispatchQueue.main.async {
                UserDefaults.standard.set(data, forKey: "receivedGrids")
            }
        }
    }
    
    static var sentGrids: [ColorGrid] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "sentGrids"),
                  let grids = try? JSONDecoder().decode([ColorGrid].self, from: data) else {
                return []
            }
            return grids
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            DispatchQueue.main.async {
                UserDefaults.standard.set(data, forKey: "sentGrids")
            }
        }
    }
    
    static var gridDuration: Int {
        get {
            let duration = UserDefaults.standard.integer(forKey: "duration")
            return duration > 0 ? duration : 5
        } set {
            DispatchQueue.main.async {
                UserDefaults.standard.set(newValue, forKey: "duration")
            }
        }
    }
    static var userId: String? {
        get {
            UserDefaults.standard.string(forKey: "userId")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userId")
        }
    }
    
    static var launchedBefore: Bool {
        get {
            UserDefaults.standard.bool(forKey: "launchedBefore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "launchedBefore")
        }
    }
    
    static var lastOpenedVersion: String? {
        get {
            UserDefaults.standard.string(forKey: "lastOpenedVersion")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastOpenedVersion")
        }
    }
}
