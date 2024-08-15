//
//  Comparable+Extensions.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/14/24.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
