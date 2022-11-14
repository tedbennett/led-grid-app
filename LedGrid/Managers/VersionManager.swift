//
//  VersionManager.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/11/2022.
//

import Foundation

struct VersionManager {
    static var versionNumber: Int {
        guard let string = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
              let number = Int(string) else { return 1 }
        return number
    }
    
    /// This will update the version number while returning true if the app has been updated
    static func checkVersionNumber() -> Bool {
        if versionNumber > Utility.lastOpenedVersion {
            Utility.lastOpenedVersion = versionNumber
            return true
        }
        return false
    }
}
