//
//  TokenHelpers.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/19/24.
//

import Foundation
import ManagedSettings

func getIdFromToken<T>(_ token: Token<T>) throws -> String {
    let tokenStr = try encodeJSONObj(token)
    return String(tokenStr.suffix(13).prefix(10))
}

