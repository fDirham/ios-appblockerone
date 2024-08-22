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
    private func isActivitySchedule(_ activity: DeviceActivityName) -> Bool {
        return activity.rawValue.starts(with: "s_")
    }
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        do {
            if isActivitySchedule(activity) {
                let ud = GroupUserDefaults()
                
                // Read from user defaults
                guard let scheduleDefault: ScheduleDefault = try? ud.getObj(forKey: activity.rawValue) else {
                    throw "Failed to decode schedule default"
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
            
            if isActivitySchedule(activity) {
                // Read from user defaults
                guard let scheduleDefault: ScheduleDefault = try? ud.getObj(forKey: activity.rawValue) else {
                    throw "Failed to decode schedule default"
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
            else { // Temp block scheduled
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
        }
        catch {
            scheduleNotification(title: "ERROR", msg: "App blocker failed \(error.localizedDescription)")
        }
    }
}
