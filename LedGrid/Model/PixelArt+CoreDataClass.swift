//
//  PixelArt+CoreDataClass.swift
//  LedGrid
//
//  Created by Ted on 11/08/2022.
//
//

import Foundation
import CoreData
import SwiftUI

func parseGrids(from strings: [String]) -> [Grid] {
    return strings.map { string in
        let components = string.components(withMaxLength: 6).map { Color(hexString: $0) }
        let size = Int(Double(components.count).squareRoot())
        return (0..<size).map {
            let index = $0 * size
            return Array(components[index..<(index + size)])
        }
    }
}

@objc(PixelArt)
public class PixelArt: NSManagedObject, Decodable {
    enum CodingKeys: String, CodingKey {
        case id, grid, sentAt, opened, gridSize, hidden, title
        case sender = "user"
        case receivers = "receiver"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
          throw DecoderConfigurationError.missingManagedObjectContext
        }

        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let encodedGrids = try (try? container.decode([String].self, forKey: .grid)) ?? [try container.decode(String.self, forKey: .grid)]
        
        self.hexGrids = encodedGrids
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try? container.decodeIfPresent(String.self, forKey: .title)
        self.sentAt = try container.decode(Date.self, forKey: .sentAt)
        self.sender = try container.decode(String.self, forKey: .sender)
        if let receivers = try? container.decode([String].self, forKey: .receivers) {
            self.receivers = receivers
        } else {
            self.receivers = [try container.decode(String.self, forKey: .receivers)]
        }
        self.opened = (try? container.decode(Bool.self, forKey: .opened)) ?? false
        self.hidden = (try? container.decode(Bool.self, forKey: .hidden)) ?? false
    }
    
    convenience init(
        id: String,
        grids: [Grid],
        title: String?,
        sender: String,
        receivers: [String],
        sentAt: Date = Date(),
        opened: Bool = false,
        hidden: Bool = false
    ) {
        self.init(context: PersistenceManager.shared.viewContext)
        self.id = id
        self.grids = grids
        self.title = title
        self.sender = sender
        self.receivers = receivers
        self.sentAt = sentAt
        self.opened = opened
        self.hidden = hidden
    }
}

extension CodingUserInfoKey {
  static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}
