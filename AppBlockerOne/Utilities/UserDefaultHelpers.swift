//
//  UserDefaultNameHelpers.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/20/24.
//
// TODO: Move these to their own respective files in UserDefaultModels

import Foundation
import ManagedSettings

func getScheduleDefaultKey(_ groupId: UUID) -> String? {
    return getScheduleDefaultKey(groupId.uuidString)
}

func getScheduleDefaultKey(_ groupId: String?) -> String? {
    if let groupId = groupId {
        return "s_\(groupId)"
    }
    return nil
}

typealias BlockItemDefaultKey = String
func getBlockedItemDefaultKey<T>(_ token: Token<T>) -> BlockItemDefaultKey? {
    do {
        let tokenId = try getIdFromToken(token)
        return getBlockedItemDefaultKey(tokenId)
    }
    catch{
        return nil
    }
}

func getBlockedItemDefaultKey(_ tokenId: String) -> BlockItemDefaultKey {
    return "bi_" + tokenId
}

func getGroupShieldDefaultKey(_ groupId: UUID) -> String? {
    return getGroupShieldDefaultKey(groupId.uuidString)
}

func getGroupShieldDefaultKey(_ groupId: String?) -> String? {
    if let groupId = groupId {
        return "gs_\(groupId)"
    }
    return nil
}

func getShieldMemoryDefaultKey<T>(_ token: Token<T>) -> String? {
    do {
        let prefix = "sm"
        let tokenId = try getIdFromToken(token)
        return prefix + "_" + tokenId
    }
    catch{
        return nil
    }
}

func getMainContentOfUserDefaultKey(udKey: String) -> String{
    if let underscoreIdx = udKey.firstIndex(of: "_") {
        let startIdx = udKey.index(underscoreIdx, offsetBy: 1)
        return String(udKey[startIdx..<udKey.endIndex])
    } else{
        return udKey
    }
}

func getScheduleEndFlagDefaultKey(_ groupId: UUID) -> String? {
    return getScheduleEndFlagDefaultKey(groupId.uuidString)
}

func getScheduleEndFlagDefaultKey(_ groupId: String?) -> String? {
    if let groupId = groupId {
        return "sef_\(groupId)"
    }
    return nil
}

func getBlockStatsDefaultKey() -> String {
    return "blockstats_"
}

let DEFAULT_KEY_TUTORIAL_DONE = "tutorialdone_"
let DEFAULT_KEY_BLOCKED_ITEM_COUNTER = "blockeditemcounter_"
let DEFAULT_KEY_BLOCKED_GROUP_COUNTER = "blockedgroupcounter_"
let DEFAULT_KEY_BLOCKED_CATEGORIES = "blockedcat_"
let DEFAULT_KEY_MAIN_SETTINGS = "mainsettings_"
