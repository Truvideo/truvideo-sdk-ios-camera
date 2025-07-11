//
// Created by TruVideo on 17/09/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

public class StdioOutputStreamMock: TextOutputStream {
    // MARK: - Properties
    
    /// Conatins the formatted message.
    public var message: String?
    
    // MARK: Initializer

    /// Initializes a new instance.
    public init() {}
    
    // MARK: TextOutputStream

    /// Appends the given string to the stream.
    public func write(_ string: String) {
        self.message = string
    }
}
