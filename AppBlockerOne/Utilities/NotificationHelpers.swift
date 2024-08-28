//
//  NotificationHelpers.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/21/24.
//

import Foundation
import UIKit

func scheduleNotification(title: String, msg bodyText: String) {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings(completionHandler: {settings in
        let canNotify = settings.authorizationStatus == .authorized && settings.alertSetting == .enabled
        if canNotify {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = bodyText
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // 5 seconds from now
            
            let request = UNNotificationRequest(identifier: "MyNotification", content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    debugPrint("Error scheduling notification: \(error)")
                }
            }
        } else {
            debugPrint("Not notifying due to lack of permissions")
        }
    })
}

func debugNotif(title: String, msg: String){
#if DEBUG
    scheduleNotification(title: title, msg: msg)
#else
    return
#endif
}
