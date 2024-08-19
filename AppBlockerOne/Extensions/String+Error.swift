//
//  String+Error.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/16/24.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
