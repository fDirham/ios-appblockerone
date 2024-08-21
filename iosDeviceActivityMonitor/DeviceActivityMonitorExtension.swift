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
    override func intervalDidStart(for activity: DeviceActivityName) {
        do {
            // Read from user defaults
            guard let scheduleDefault: ScheduleDefault = try? GroupUserDefaults().getObj(forKey: activity.rawValue) else {
                throw "Failed to decode schedule default"
            }
            
            // Block apps
            try blockApps(faSelection: scheduleDefault.faSelection)
        }
        catch {
            scheduleNotification(title: "ERROR", msg: "App blocker failed \(error.localizedDescription)")
        }
            
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        do {
            // Read from user defaults
            guard let scheduleDefault: ScheduleDefault = try? GroupUserDefaults().getObj(forKey: activity.rawValue) else {
                throw "Failed to decode schedule default"
            }

            // Unblock apps
            try unblockApps(faSelection: scheduleDefault.faSelection)
        }
        catch {
            scheduleNotification(title: "ERROR", msg: "App blocker failed \(error.localizedDescription)")
        }
    }
}
