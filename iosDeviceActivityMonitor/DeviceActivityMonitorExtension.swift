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
    func scheduleNotification(title: String, msg bodyText: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = title // Using the custom title here
                content.body = bodyText
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // 5 seconds from now
                
                let request = UNNotificationRequest(identifier: "MyNotification", content: content, trigger: trigger)
                
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            } else {
                print("Permission denied. \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        do {
            // Read from user defaults
            let faRaw = GroupUserDefaults().string(forKey: activity.rawValue)!
            let faSelection: FamilyActivitySelection = try decodeJSONObj(faRaw)
            
            // Block apps
            try blockApps(faSelection: faSelection)
        }
        catch {
            scheduleNotification(title: "ERROR", msg: "App blocker failed \(error.localizedDescription)")
        }
            
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        do {
            // Read from user defaults
            let faRaw = GroupUserDefaults().string(forKey: activity.rawValue)!
            let faSelection: FamilyActivitySelection = try decodeJSONObj(faRaw)
            
            // Unblock apps
            try unblockApps(faSelection: faSelection)
        }
        catch {
            scheduleNotification(title: "ERROR", msg: "App blocker failed \(error.localizedDescription)")
        }
    }
}
