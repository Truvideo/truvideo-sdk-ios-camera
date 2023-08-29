//
//  ResponseDTO.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// A structure representing the response format used in some
/// endpoints of the app.
struct ResponseDTO<T: Decodable>: Decodable {
    /// The associated data content.
    let data: T?
}
