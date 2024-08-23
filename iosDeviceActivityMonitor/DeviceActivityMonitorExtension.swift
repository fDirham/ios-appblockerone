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
    private func isScheduleActivity(_ activity: DeviceActivityName) -> Bool {
        return activity.rawValue.starts(with: "s_")
    }
    
    private func isTempBlockActivity(_ activity: DeviceActivityName) -> Bool {
        return activity.rawValue.starts(with: "tb_")
    }
    
    private func isWipeBlockStatsActivity(_ activity: DeviceActivityName) -> Bool {
        return activity.rawValue == BLOCK_STATS_DA_NAME.rawValue
    }

    override func intervalDidStart(for activity: DeviceActivityName) {
        do {
            if isScheduleActivity(activity) {
                let ud = GroupUserDefaults()
                
                // Read from user defaults
                guard let scheduleDefault: ScheduleDefault = try? ud.getObj(forKey: activity.rawValue) else {
                    throw "Failed to decode schedule default for did start"
                }
                
                let groupId = getMainContentOfUserDefaultKey(udKey: activity.rawValue)
                guard let sefKey = getScheduleEndFlagDefaultKey(groupId) else {
                    throw "Can't generate SEF key"
                }
                ud.set(false, forKey: sefKey)
                
                // Block apps
                try blockApps(faSelection: scheduleDefault.faSelection)
            }
        }
        catch {
            scheduleNotification(title: "ERROR", msg: "App blocker failed \(error.localizedDescription)")
        }
            
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        do {
            let ud = GroupUserDefaults()
            
            if isScheduleActivity(activity) {
                // Read from user defaults
                guard let scheduleDefault: ScheduleDefault = try? ud.getObj(forKey: activity.rawValue) else {
                    throw "Failed to decode schedule default for did end \(activity.rawValue)"
                }
                
                // Set SEF
                let groupId = getMainContentOfUserDefaultKey(udKey: activity.rawValue)
                guard let sefKey = getScheduleEndFlagDefaultKey(groupId) else {
                    throw "Can't generate SEF key"
                }
                ud.set(true, forKey: sefKey)

                // Unblock apps
                try unblockApps(faSelection: scheduleDefault.faSelection)
            }
            else if isTempBlockActivity(activity) { // Temp block scheduled
                // Make sure schedule hasn't ended yet
                let groupId = getMainContentOfUserDefaultKey(udKey: activity.rawValue)
                guard let sefKey = getScheduleEndFlagDefaultKey(groupId) else {
                    throw "Can't generate SEF key"
                }
                if ud.bool(forKey: sefKey) {
                    return
                }
                
                let sKey = getScheduleDefaultKey(groupId)!
                guard let scheduleDefault: ScheduleDefault = try? ud.getObj(forKey: sKey) else {
                    throw "Failed to decode schedule default"
                }
                
                // Block apps
                try blockApps(faSelection: scheduleDefault.faSelection)
            }
            else if isWipeBlockStatsActivity(activity) {
                ud.removeObject(forKey: getBlockStatsDefaultKey())
            }
        }
        catch {
            scheduleNotification(title: "ERROR", msg: "App blocker failed \(error.localizedDescription)")
        }
    }
}
