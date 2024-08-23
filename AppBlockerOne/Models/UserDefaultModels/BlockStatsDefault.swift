//
//  BlockStatsDefault.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/22/24.
//

import Foundation
import ManagedSettings

struct BlockStatsDefault: Codable {
    var blockDict: Dictionary<BlockItemDefaultKey, BlockItemStat>
    
    mutating func setBlockItemStat<T>(_ blockItemStat: BlockItemStat, forToken: Token<T>) throws {
        let tokenId = try getIdFromToken(forToken)
        self.blockDict[tokenId] = blockItemStat
    }
    
    func getBlockItemStat<T>(forToken: Token<T>) throws -> BlockItemStat?{
        let tokenId = try getIdFromToken(forToken)
        return self.blockDict[tokenId]
    }
}

struct BlockItemStat: Codable {
    var countTodayOpened: Int
}
