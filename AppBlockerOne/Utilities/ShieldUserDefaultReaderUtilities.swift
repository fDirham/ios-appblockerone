//
//  ShieldUserDefaultReaderUtilities.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/21/24.
//

import Foundation
import ManagedSettings

func readShieldUserDefaultEssentials<T>(appToken: Token<T>?) throws -> (blockedItem: BlockedItemDefault, groupShield: GroupShieldDefault, shieldMemory: ShieldMemory?, blockStats: BlockStatsDefault?, mainSettings: MainSettingsDefault ,keys: (smKey: String, gsKey: String, bsKey: String)){
    guard let token = appToken else {
        throw "Cannot find app token"
    }
    
    guard let blockedItemKey = getBlockedItemDefaultKey(token) else {
        throw "Cannot find blocked item key for app"
    }
    
    let ud = GroupUserDefaults()
    guard let blockedItem: BlockedItemDefault = try ud.getObj(forKey: blockedItemKey) else {
        throw "Cannot find blocked item obj for app"
    }
    
    guard let gsKey = getGroupShieldDefaultKey(blockedItem.groupId) else {
        throw "Cannot generate group shield key"
    }
    
    guard let groupShield: GroupShieldDefault = try? ud.getObj(forKey: gsKey) else {
        throw "Cannot decode group shield for app"
    }
    
    guard let smKey = getShieldMemoryDefaultKey(token) else {
        throw "Cannot get shield memory key"
    }
    
    let shieldMemory: ShieldMemory? = try ud.getObj(forKey: smKey)
    
    let bsKey = getBlockStatsDefaultKey()
    let blockStats: BlockStatsDefault? = try ud.getObj(forKey: bsKey)
    
    let mainSettings: MainSettingsDefault = try ud.getObj(forKey: DEFAULT_KEY_MAIN_SETTINGS) ?? MainSettingsDefault()
    
    return (
        blockedItem: blockedItem,
        groupShield: groupShield,
        shieldMemory: shieldMemory,
        blockStats: blockStats,
        mainSettings: mainSettings,
        keys: (
            smKey: smKey,
            gsKey: gsKey,
            bsKey: bsKey
        )
    )
}
