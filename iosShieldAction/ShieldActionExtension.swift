//
//  ShieldActionExtension.swift
//  iosShieldAction
//
//  Created by Fajar Dirham on 8/20/24.
//

import ManagedSettings
import UIKit
import SwiftUI

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            do{
                let d = try readShieldUserDefaultEssentials(appToken: application)
                var shieldMemory = d.shieldMemory ?? ShieldMemory()
                shieldMemory.backTapCount += 1
                let MAX_TAPS = 5
                if shieldMemory.backTapCount >= MAX_TAPS {
                    // Unblock!
                    var toUnblock: Set<ApplicationToken> = Set()
                    toUnblock.insert(application)
                    try unblockApps(appTokens: toUnblock)
                    
                    // Delete shield memory
                    let ud = GroupUserDefaults()
                    ud.removeObject(forKey: d.keys.smKey)

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
                scheduleNotification(title: "action error", msg: error.localizedDescription)
                completionHandler(.none)
            }
        @unknown default:
            fatalError()
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        completionHandler(.close)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        completionHandler(.close)
    }
}
