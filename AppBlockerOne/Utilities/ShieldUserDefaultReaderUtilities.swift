//
//  ShieldUserDefaultReaderUtilities.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/21/24.
//

import Foundation
import ManagedSettings

func readShieldUserDefaultEssentials<T>(appToken: Token<T>?) throws -> (blockedItem: String, groupShield: GroupShieldDefault, shieldMemory: ShieldMemory?, keys: (smKey: String, gsKey: String)){
    guard let token = appToken else {
        throw "Cannot find app token"
    }
    
    guard let blockedItemKey = getBlockedItemDefaultKey(token) else {
        throw "Cannot find blocked item key for app"
    }
    
    let ud = GroupUserDefaults()
    guard let blockedItem = ud.string(forKey: blockedItemKey) else {
        throw "Cannot find blocked item obj for app"
    }
    
    guard let gsKey = getGroupShieldDefaultKey(blockedItem) else {
        throw "Cannot generate group shield key"
    }
    
    guard let groupShield: GroupShieldDefault = try? ud.getObj(forKey: gsKey) else {
        throw "Cannot decode group shield for app"
    }
    
    guard let smKey = getShieldMemoryDefaultKey(token) else {
        throw "Cannot get shield memory key"
    }
    
    let shieldMemory: ShieldMemory? = try ud.getObj(forKey: smKey)
    
    return (
        blockedItem: blockedItem,
        groupShield: groupShield,
        shieldMemory: shieldMemory,
        keys: (
            smKey: smKey,
            gsKey: gsKey
        )
    )
}
