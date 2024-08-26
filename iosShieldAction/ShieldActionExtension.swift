//
//  ShieldActionExtension.swift
//  iosShieldAction
//
//  Created by Fajar Dirham on 8/20/24.
//

import ManagedSettings
import UIKit
import SwiftUI
import DeviceActivity

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        mainHandler(action: action, for: application, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        mainHandler(action: action, for: webDomain, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        mainHandler(action: action, for: category, completionHandler: completionHandler)
    }
    
    private func mainHandler<T>(action: ShieldAction, for itemToken: Token<T>, completionHandler: @escaping (ShieldActionResponse) -> Void){
        switch action {
        case .primaryButtonPressed:
            if let smKey = getShieldMemoryDefaultKey(itemToken) {
                let ud = GroupUserDefaults()
                ud.removeObject(forKey: smKey)
            }
            completionHandler(.close)
        case .secondaryButtonPressed:
            do{
                let d = try readShieldUserDefaultEssentials(appToken: itemToken)
                var shieldMemory = d.shieldMemory ?? ShieldMemory()
                shieldMemory.backTapCount += 1
                let maxTaps = d.groupShield.maxTaps
                if shieldMemory.backTapCount >= maxTaps {
                    // Unblock app
                    if type(of: itemToken) == ApplicationToken.self {
                        let toUnblock: Set<ApplicationToken> = Set([itemToken as! ApplicationToken])
                        try unblockApps(appTokens: toUnblock)
                    }
                    else if type(of: itemToken) == WebDomainToken.self {
                        let toUnblock: Set<WebDomainToken> = Set([itemToken as! WebDomainToken])
                        try unblockApps(webTokens: toUnblock)
                    }
                    else if type(of: itemToken) == ActivityCategoryToken.self {
                        let toUnblock: Set<ActivityCategoryToken> = Set([itemToken as! ActivityCategoryToken])
                        try unblockApps(catTokens: toUnblock)
                    }

                    // Delete shield memory
                    let ud = GroupUserDefaults()
                    ud.removeObject(forKey: d.keys.smKey)
                    
                    // Set schedule
                    try scheduleTempUnblock(unblockDurationM: d.groupShield.durationPerOpenM, itemToken: itemToken)
                    
                    // Add to block stats
                    let isNewBlockStats = d.blockStats == nil
    
                    var blockStats = d.blockStats ?? BlockStatsDefault(blockDict: [:])
                    var blockItemStat = try blockStats.getBlockItemStat(forToken: itemToken) ?? BlockItemStat(countTodayOpened: 0)
                    blockItemStat.countTodayOpened += 1
                    
                    // Save
                    try blockStats.setBlockItemStat(blockItemStat, forToken: itemToken)
                    try ud.setObj(blockStats, forKey: d.keys.bsKey)
                    
                    // Schedule to wipe if new
                    if isNewBlockStats {
                       try scheduleBlockStatsWipe()
                    }
                    
                    completionHandler(.none)
                }
                else{
                    // Save shield memory
                    let ud = GroupUserDefaults()
                    try ud.setObj(shieldMemory, forKey: d.keys.smKey)
                    
                    completionHandler(.defer)
                }
            }
            catch{
                debugNotif(title: "SA ERROR", msg: error.localizedDescription)
                completionHandler(.none)
            }
        @unknown default:
            fatalError()
        }
    }
    
    private func scheduleTempUnblock<T>(unblockDurationM: Int, itemToken: Token<T>) throws {
        let calendar = Calendar.current
        let currDate = Date()
        var startInterval = DateComponents()
        startInterval.hour = calendar.component(.hour, from: currDate)
        startInterval.minute = calendar.component(.minute, from: currDate)
        
        let UNBLOCK_MINUTES = unblockDurationM
        let unblockS: Double = Double(UNBLOCK_MINUTES * 60)
        let endDate = Date(timeIntervalSinceNow: unblockS)
        var endInterval = DateComponents()
        endInterval.hour = calendar.component(.hour, from: endDate)
        endInterval.minute = calendar.component(.minute, from: endDate)

        let schedule = DeviceActivitySchedule(
            intervalStart: startInterval, intervalEnd: endInterval, repeats: false
        )
        
        // Start monitoring
        guard let deviceActivityName = getTempUnblockDAName(token: itemToken) else {
            throw "Cannot get temp unblock DA name"
        }
        
        let center = DeviceActivityCenter()
        try center.startMonitoring(deviceActivityName, during: schedule)
    }
    
    private func scheduleBlockStatsWipe() throws {
        var startInterval = DateComponents()
        startInterval.hour = 0
        startInterval.minute = 0
        
        var endInterval = DateComponents()
        endInterval.hour = 23
        endInterval.minute = 59

        let schedule = DeviceActivitySchedule(
            intervalStart: startInterval, intervalEnd: endInterval, repeats: false
        )
        
        // Start monitoring
        let deviceActivityName = BLOCK_STATS_DA_NAME
        let center = DeviceActivityCenter()
        try center.startMonitoring(deviceActivityName, during: schedule)
    }
}
