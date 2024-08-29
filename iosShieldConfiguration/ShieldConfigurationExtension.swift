//
//  ShieldConfigurationExtension.swift
//  iosShieldConfiguration
//
//  Created by Fajar Dirham on 8/19/24.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        guard let itemToken = application.token else {
            return fallbackConfig(debugText: "Cannot get item token")
        }
        let itemName = application.localizedDisplayName ?? "this app"
        return masterConfig(itemToken: itemToken, itemName: itemName)
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        guard let itemToken = category.token else {
            return fallbackConfig(debugText: "Cannot get item token")
        }
        let itemName = category.localizedDisplayName != nil ? "apps in the \(category.localizedDisplayName!) category" : "apps of the same category"
        return masterConfig(itemToken: itemToken, itemName: itemName)
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        guard let itemToken = webDomain.token else {
            return fallbackConfig(debugText: "Cannot get item token")
        }
        let itemName = "this site"
        return masterConfig(itemToken: itemToken, itemName: itemName)
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        guard let itemToken = category.token else {
            return fallbackConfig(debugText: "Cannot get item token")
        }
        let itemName = category.localizedDisplayName != nil ? "sites in the \(category.localizedDisplayName!) category" : "sites of the same category"
        return masterConfig(itemToken: itemToken, itemName: itemName)
    }
    
    private func masterConfig<T>(itemToken: Token<T>, itemName: String) -> ShieldConfiguration {
        do {
            let d = try readShieldUserDefaultEssentials(appToken: itemToken)
            
            // Instantiate title and subtitle
            let titleText = "Blocked" // TODO: More stylistic text
            let numOpened = try d.blockStats?.getBlockItemStat(forToken: itemToken)?.countTodayOpened ?? 0
            let maxOpened = d.groupShield.maxOpensPerDay
            let isStrictBlock = d.groupShield.strictBlock || numOpened >= maxOpened
            let unblockTotalTimeM = d.groupShield.durationPerOpenM * numOpened
            
            var subtitleText = "\(itemName) opens: \(numOpened)/\(maxOpened) times \n Total: \(unblockTotalTimeM) mins."
            let primaryButtonText = "Nevermind"
            let secondaryButtonText = "Let me in!"
            
            if !isStrictBlock {
                if let shieldMemory: ShieldMemory = d.shieldMemory  {
                    if shieldMemory.backTapCount > 0 {
                        let MAX_TAP_COUNT = 5
                        let leftovers = MAX_TAP_COUNT - shieldMemory.backTapCount
                        subtitleText = "Tap \(leftovers) more times \nto unblock..."
                    }
                }
            }
            else {
                subtitleText = "Stay calm, be focused..."
            }
            
            let shieldTitle = ShieldConfiguration.Label(text: titleText, color: .fg)
            let shieldSubtitle = ShieldConfiguration.Label(text: subtitleText, color: .fg)
            let primaryButtonLabel = ShieldConfiguration.Label(text: primaryButtonText, color: .black)
            var secondaryButtonLabel: ShieldConfiguration.Label? = ShieldConfiguration.Label(text: secondaryButtonText, color: .black)
            
            if isStrictBlock {
                secondaryButtonLabel = nil
            }
            
            var shieldIcon: UIImage? = nil
            if d.mainSettings.usePremiumShield ?? false { 
                shieldIcon = UIImage(named: "premiumShieldIcon")
            }
            
            return ShieldConfiguration(
                backgroundBlurStyle: .systemUltraThinMaterial,
                backgroundColor: .bg,
                icon: shieldIcon,
                title: shieldTitle,
                subtitle: shieldSubtitle,
                primaryButtonLabel: primaryButtonLabel,
                primaryButtonBackgroundColor: .accent,
                secondaryButtonLabel: secondaryButtonLabel
            )
        }
        catch {
            return fallbackConfig(debugText: error.localizedDescription)
        }
    }
    
    private func fallbackConfig(debugText: String?) -> ShieldConfiguration{
        let subtitleText = debugText ?? "Error"
        let subtitleLabel = ShieldConfiguration.Label(text: subtitleText, color: .black)
        return ShieldConfiguration(backgroundColor: .bg, subtitle: subtitleLabel)
    }
}
