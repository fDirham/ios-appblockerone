//
//  BlockSettingsHelpers.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/16/24.
//

import Foundation
import ManagedSettings
import FamilyControls

let BLOCKED_CATEGORIES_KEY = "blocked_cat"
let managedSettingsStore = ManagedSettingsStore()

func blockApps(faSelection: FamilyActivitySelection) throws {
    let store = managedSettingsStore
    
    // Block apps
    let newBlockedApps = faSelection.applicationTokens
    if !newBlockedApps.isEmpty{
        var toAdd: Set<ApplicationToken> = newBlockedApps
        if let currApps = store.shield.applications {
            toAdd = currApps.union(toAdd)
        }
        store.shield.applications = toAdd
    }
    
    let newBlockedWeb = faSelection.webDomainTokens
    if !newBlockedWeb.isEmpty{
        var toAdd: Set<WebDomainToken> = newBlockedWeb
        if let currWeb = store.shield.webDomains {
            toAdd = currWeb.union(toAdd)
        }
        store.shield.webDomains = toAdd
    }
    
    
    let newBlockedCat = faSelection.categoryTokens
    if !newBlockedCat.isEmpty{
        // Read from user defaults
        var toAdd: Set<ActivityCategoryToken> = Set()
        if let blockedCatRaw = UserDefaults(suiteName: "group.appblockerone")!.string(forKey: BLOCKED_CATEGORIES_KEY) {
            let blockedCat: Set<ActivityCategoryToken> = try decodeJSONObj(blockedCatRaw)
            toAdd = blockedCat
        }
        toAdd = toAdd.union(newBlockedCat)
        store.shield.applicationCategories = .specific(toAdd)
        store.shield.webDomainCategories = .specific(toAdd)
        
        let saveString = try encodeJSONObj(toAdd)
        UserDefaults(suiteName: "group.appblockerone")!.set(toAdd, forKey: BLOCKED_CATEGORIES_KEY)
    }
}

func unblockApps(faSelection: FamilyActivitySelection) throws {
    let store = managedSettingsStore
    
    // Unblock apps
    let newBlockedApps = faSelection.applicationTokens
    if !newBlockedApps.isEmpty{
        if let currApps = store.shield.applications {
            store.shield.applications = currApps.subtracting(newBlockedApps)
        }
        else {
            store.shield.applications = nil
        }
    }
    
    let newBlockedWeb = faSelection.webDomainTokens
    if !newBlockedWeb.isEmpty{
        if let currWeb = store.shield.webDomains {
            store.shield.webDomains = currWeb.subtracting(newBlockedWeb)
        }
        else {
            store.shield.webDomains = nil
        }
    }
    
    
    let newBlockedCat = faSelection.categoryTokens
    if !newBlockedCat.isEmpty{
        // Read from user defaults
        if let blockedCatRaw = UserDefaults(suiteName: "group.appblockerone")!.string(forKey: BLOCKED_CATEGORIES_KEY) {
            let blockedCat: Set<ActivityCategoryToken> = try decodeJSONObj(blockedCatRaw)
            let toAdd = blockedCat.subtracting(newBlockedCat)
            store.shield.applicationCategories = .specific(toAdd)
            store.shield.webDomainCategories = .specific(toAdd)
            
            let saveString = try encodeJSONObj(toAdd)
            UserDefaults(suiteName: "group.appblockerone")!.set(toAdd, forKey: BLOCKED_CATEGORIES_KEY)
        }
        else {
            store.shield.applicationCategories = nil
            store.shield.webDomainCategories = nil
        }
    }
}
