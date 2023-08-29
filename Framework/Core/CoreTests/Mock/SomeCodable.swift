//
//  SomeCodable.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// This class wiil be use alone for testing
struct SomeCodable: Codable {
    /// This is a `String` value
    let string: String
    
    /// This is a `Int` value.
    let int: Int
    
    /// This is a `Bool` value.
    let bool: Bool
    
    /// This is a `String` value.
    let hasUnderscore: String
    
    /// 
    enum CodingKeys: String,CodingKey {
        case string
        case int
        case bool
        case hasUnderscore = "has_underscore"
    }
}
