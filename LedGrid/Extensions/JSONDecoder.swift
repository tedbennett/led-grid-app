//
//  JSONDecoder.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation

extension JSONDecoder {
    static var standard: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
