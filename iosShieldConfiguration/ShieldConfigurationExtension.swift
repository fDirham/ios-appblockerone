//
//  ShieldConfigurationExtension.swift
//  iosShieldConfiguration
//
//  Created by Fajar Dirham on 8/19/24.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import CoreData

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        do {
            guard let token = application.token else {
                throw "Cannot find app token for app \(application.localizedDisplayName ?? "?")"
            }
            
            guard let blockedItemKey = getBlockedItemDefaultKey(token) else {
                throw "Cannot find blocked item key for app \(application.localizedDisplayName ?? "?")"
            }
            
            let ud = GroupUserDefaults()
            guard let blockedItem = ud.string(forKey: blockedItemKey) else {
                throw "Cannot find blocked item obj for app \(application.localizedDisplayName ?? "?")"
            }
            
            guard let gsKey = getGroupShieldDefaultKey(blockedItem) else {
                throw "Cannot generate group shield key \(application.localizedDisplayName ?? "?")"
            }
            
            guard let groupShieldRaw = ud.string(forKey: gsKey) else {
                throw "Cannot find group shield raw obj with key: \(gsKey)"
            }
            
            guard let groupShield: GroupShieldDefault = try? decodeJSONObj(groupShieldRaw) else {
                throw "Cannot decode group shield for app \(application.localizedDisplayName ?? "?")"
            }
            
            let shieldTitle = ShieldConfiguration.Label(text: "Nope!", color: .fg)
            let shieldSubtitle = ShieldConfiguration.Label(text: "Today, you have unblocked \"\(groupShield.groupName)\" apps 5/10 times, for a total of 1h 32 mins.", color: .fg)
            let primaryButtonLabel = ShieldConfiguration.Label(text: "Nevermind", color: .black)
            let secondaryButtonLabel = ShieldConfiguration.Label(text: "Let me in!", color: .accent)
            return ShieldConfiguration(
                backgroundBlurStyle: .systemUltraThinMaterial,
                backgroundColor: .bg,
                title: shieldTitle,
                subtitle: shieldSubtitle,
                primaryButtonLabel: primaryButtonLabel,
                primaryButtonBackgroundColor: .accent,
                secondaryButtonLabel: secondaryButtonLabel
            )
        }
        catch {
            let secondaryButtonLabel = ShieldConfiguration.Label(text: "Error \(error.localizedDescription)", color: .black)
            return ShieldConfiguration(backgroundColor: .bg)
        }
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        let subtitle = ShieldConfiguration.Label(text: "CATEGORY \(category.localizedDisplayName ?? "?")", color: .black)
        let toReturn = ShieldConfiguration(backgroundColor: .white, subtitle: subtitle)

        return toReturn
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        ShieldConfiguration()
    }
}
