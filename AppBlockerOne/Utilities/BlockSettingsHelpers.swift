//
//  BlockSettingsHelpers.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/16/24.
//

import Foundation
import ManagedSettings
import FamilyControls

let managedSettingsStore = ManagedSettingsStore()

func blockApps(faSelection: FamilyActivitySelection) throws {
    try blockApps(appTokens: faSelection.applicationTokens, webTokens: faSelection.webDomainTokens, catTokens: faSelection.categoryTokens)
}

func blockApps(appTokens newBlockedApps: Set<ApplicationToken> = Set(), webTokens newBlockedWeb: Set<WebDomainToken> = Set(), catTokens newBlockedCat: Set<ActivityCategoryToken> = Set()) throws {
    let store = managedSettingsStore
    let ud = GroupUserDefaults()
    
    // Block apps
    if !newBlockedApps.isEmpty{
        var toAdd: Set<ApplicationToken> = newBlockedApps
        if let currApps = store.shield.applications {
            toAdd = currApps.union(toAdd)
        }
        store.shield.applications = toAdd
    }
    
    if !newBlockedWeb.isEmpty{
        var toAdd: Set<WebDomainToken> = newBlockedWeb
        if let currWeb = store.shield.webDomains {
            toAdd = currWeb.union(toAdd)
        }
        store.shield.webDomains = toAdd
    }
    
    
    if !newBlockedCat.isEmpty{
        // Read from user defaults
        var toAdd: Set<ActivityCategoryToken> = Set()
        if let blockedCat: Set<ActivityCategoryToken> = try ud.getObj(forKey: DEFAULT_KEY_BLOCKED_CATEGORIES) {
            toAdd = blockedCat
        }
        
        toAdd = toAdd.union(newBlockedCat)
        store.shield.applicationCategories = .specific(toAdd)
        store.shield.webDomainCategories = .specific(toAdd)
        
        try ud.setObj(toAdd, forKey: DEFAULT_KEY_BLOCKED_CATEGORIES)
    }
}

func unblockApps(faSelection: FamilyActivitySelection) throws {
    try unblockApps(appTokens: faSelection.applicationTokens, webTokens: faSelection.webDomainTokens, catTokens: faSelection.categoryTokens)
}

func unblockApps(appTokens newBlockedApps: Set<ApplicationToken> = Set(), webTokens newBlockedWeb: Set<WebDomainToken> = Set(), catTokens newBlockedCat: Set<ActivityCategoryToken> = Set()) throws {
    let store = managedSettingsStore
    let ud = GroupUserDefaults()

    // Unblock apps
    if !newBlockedApps.isEmpty{
        if let currApps = store.shield.applications {
            let toSet = currApps.subtracting(newBlockedApps)
            store.shield.applications = toSet
        }
        else {
            store.shield.applications = nil
        }
    }
    
    if !newBlockedWeb.isEmpty{
        if let currWeb = store.shield.webDomains {
            let toSet = currWeb.subtracting(newBlockedWeb)
            store.shield.webDomains = toSet
        }
        else {
            store.shield.webDomains = nil
        }
    }
    
    
    if !newBlockedCat.isEmpty{
        // Read from user defaults
        if let blockedCat: Set<ActivityCategoryToken> = try ud.getObj(forKey: DEFAULT_KEY_BLOCKED_CATEGORIES) {
            let toAdd = blockedCat.subtracting(newBlockedCat)
            store.shield.applicationCategories = .specific(toAdd)
            store.shield.webDomainCategories = .specific(toAdd)
            try ud.setObj(toAdd, forKey: DEFAULT_KEY_BLOCKED_CATEGORIES)
        }
        else {
            store.shield.applicationCategories = nil
            store.shield.webDomainCategories = nil
        }
    }
}
