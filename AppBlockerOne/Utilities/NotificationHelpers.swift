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

