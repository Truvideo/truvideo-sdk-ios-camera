//
//  Operators.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

infix operator ++
func + <T>(lhs: [String: T], rhs: [String: T]) -> [String: T] {
    lhs.merging(rhs, uniquingKeysWith: { _, new in new })
}
