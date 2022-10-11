//
//  Date.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation

extension Date {
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        if let month = Calendar.current.dateComponents([.month], from: self, to: Date()).month, month < 11 {
            dateFormatter.dateFormat = "MMM d"
        } else {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
        }
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }
}
