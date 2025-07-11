//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

infix operator + : AdditionPrecedence
func + (lhs: [String: String], rhs: [String: String]) -> [String: String] {
    lhs.merging(rhs, uniquingKeysWith: { _, rhs in rhs })
}
