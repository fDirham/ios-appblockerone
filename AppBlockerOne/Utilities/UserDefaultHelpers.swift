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

func getBlockedItemDefaultKey<T>(_ token: Token<T>) -> String? {
    do {
        var prefix = ""
        if type(of: token) == ApplicationToken.self {
            prefix = "bia_"
        }
        else if type(of: token) == WebDomainToken.self {
            prefix = "biw_"
        }
        else if type(of: token) == ActivityCategoryToken.self {
            prefix = "bic"
        }
        
        let tokenId = try getIdFromToken(token)
        return prefix + "_" + tokenId
    }
    catch{
        return nil
    }
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
