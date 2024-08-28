//
//  DeviceActivityMonitorExtension.swift
//  iosDeviceActivityMonitor
//
//  Created by Fajar Dirham on 8/16/24.
//

import DeviceActivity
import ManagedSettings
import UserNotifications
import FamilyControls

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private func isBlockScheduleActivity(_ activity: DeviceActivityName) -> Bool {
        return activity.rawValue.starts(with: "bs_")
    }
    
    private func isTempUnblockActivity(_ activity: DeviceActivityName) -> Bool {
        return activity.rawValue.starts(with: "tu_")
    }
    
    private func isWipeBlockStatsActivity(_ activity: DeviceActivityName) -> Bool {
        return activity.rawValue == BLOCK_STATS_DA_NAME.rawValue
    }

    override func intervalDidStart(for activity: DeviceActivityName) {
        do {
            if isBlockScheduleActivity(activity) {
                let ud = GroupUserDefaults()
                
                // Read from user defaults
                let groupId = getMainContentsOfDAName(daName: activity)
                guard let sKey = getScheduleDefaultKey(groupId) else {
                    throw "Can't generate schedule default key"
                }
                
                guard let scheduleDefault: ScheduleDefault = try? ud.getObj(forKey: sKey) else {
                    throw "Failed to decode schedule default for did start"
                }
                
                // Block apps
                try blockApps(faSelection: scheduleDefault.faSelection)
                
                guard let sefKey = getScheduleEndFlagDefaultKey(groupId) else {
                    throw "Can't generate SEF key"
                }
                ud.set(false, forKey: sefKey)
                
                scheduleNotification(title: "\(scheduleDefault.groupName) blocked!", msg: "\(APP_NAME) has blocked apps in the \"\(scheduleDefault.groupName)\" group.")
            }
        }
        catch {
            debugNotif(title: "DAM ERROR", msg: "\(error.localizedDescription)")
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        debugNotif(title: "DAM", msg: "Ending activity: \(activity.rawValue)")
        do {
            let ud = GroupUserDefaults()
            
            if isBlockScheduleActivity(activity) {
                // Read from user defaults
                let groupId = getMainContentsOfDAName(daName: activity)
                
                guard let sKey = getScheduleDefaultKey(groupId) else {
                    throw "Can't generate schedule default key"
                }
                
                guard let scheduleDefault: ScheduleDefault = try? ud.getObj(forKey: sKey) else {
                    throw "Failed to decode schedule default for did end \(activity.rawValue)"
                }
                
                // Set SEF
                guard let sefKey = getScheduleEndFlagDefaultKey(groupId) else {
                    throw "Can't generate SEF key"
                }
                ud.set(true, forKey: sefKey)

                // Unblock apps
                try unblockApps(faSelection: scheduleDefault.faSelection)
                
                scheduleNotification(title: "\(scheduleDefault.groupName) unblocked!", msg: "\(APP_NAME) has unblocked apps in the \"\(scheduleDefault.groupName)\" group.")
            }
            else if isTempUnblockActivity(activity) { // Temp block scheduled
                let tokenId = getMainContentsOfDAName(daName: activity)

                // Make sure schedule hasn't ended yet by checking blocked items
                let biKey = getBlockedItemDefaultKey(tokenId)
                guard let blockedItem: BlockedItemDefault = try ud.getObj(forKey: biKey) else {
                    throw "Cannot find blocked item default"
                }

                let groupId = blockedItem.groupId
                guard let sefKey = getScheduleEndFlagDefaultKey(groupId) else {
                    throw "Can't generate SEF key"
                }
                if ud.bool(forKey: sefKey) {
                    return
                }
                
                // Block apps if we need to
                if blockedItem.appToken != nil {
                    try blockApps(appTokens: Set([blockedItem.appToken!]))
                }
                if blockedItem.webToken != nil {
                    try blockApps(webTokens: Set([blockedItem.webToken!]))
                }
                if blockedItem.catToken != nil {
                    try blockApps(catTokens: Set([blockedItem.catToken!]))
                }
                
                scheduleNotification(title: "Temporary unblock has ended", msg: "\(APP_NAME) has blocked your app once again.")
            }
            else if isWipeBlockStatsActivity(activity) {
                ud.removeObject(forKey: getBlockStatsDefaultKey())
                debugNotif(title: "DAM", msg: "Wiped block stats \(activity.rawValue)")
            }
        }
        catch {
            debugNotif(title: "DAM ERROR", msg: "\(error.localizedDescription)")
        }
    }
}
