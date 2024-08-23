//
//  ScheduleHelpers.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/22/24.
//

import Foundation
import DeviceActivity
import ManagedSettings

let BLOCK_STATS_DA_NAME = DeviceActivityName("wipe-block-stats_")

func getBlockScheduleDAName(groupId: UUID) -> DeviceActivityName {
    return getBlockScheduleDAName(groupId: groupId.uuidString)
}

func getBlockScheduleDAName(groupId: String) -> DeviceActivityName {
    return DeviceActivityName("bs_\(groupId)")
}

func getTempUnblockDAName<T>(token: Token<T>) -> DeviceActivityName? {
    do {
        let tokenId = try getIdFromToken(token)
        return getTempUnblockDAName(tokenId: tokenId)
    }
    catch{
        return nil
    }
}

func getTempUnblockDAName(tokenId: String) -> DeviceActivityName {
    return DeviceActivityName("tu_\(tokenId)")
}

func getMainContentsOfDAName(daName: DeviceActivityName) -> String {
    let udKey = daName.rawValue
    if let underscoreIdx = udKey.firstIndex(of: "_") {
        let startIdx = udKey.index(underscoreIdx, offsetBy: 1)
        return String(udKey[startIdx..<udKey.endIndex])
    } else{
        return udKey
    }
}

