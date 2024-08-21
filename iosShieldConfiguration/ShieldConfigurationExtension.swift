//
//  ShieldConfigurationExtension.swift
//  iosShieldConfiguration
//
//  Created by Fajar Dirham on 8/19/24.
//

import ManagedSettings
import ManagedSettingsUI

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        do {
            let d = try readShieldUserDefaultEssentials(appToken: application.token)
            
            // Instantiate title and subtitle
            var titleText = "Blocked" // TODO: More stylistic text
            var subtitleText = "Today, you have unblocked \"\(d.groupShield.groupName)\" apps 5/10 times, for a total of 1h 32 mins."
            var primaryButtonText = "Nevermind"
            var secondaryButtonText = "Let me in!"
            
            if let shieldMemory: ShieldMemory = d.shieldMemory  {
                if shieldMemory.backTapCount > 0 {
                    let MAX_TAP_COUNT = 5 // TODO: Make this a setting
                    let leftovers = MAX_TAP_COUNT - shieldMemory.backTapCount
                    subtitleText = "Are you sure? Tap \(leftovers) more times to confirm..."
                    // TODO: Change title text too
                }
            }
            
            let shieldTitle = ShieldConfiguration.Label(text: titleText, color: .fg)
            let shieldSubtitle = ShieldConfiguration.Label(text: subtitleText, color: .fg)
            let primaryButtonLabel = ShieldConfiguration.Label(text: primaryButtonText, color: .black)
            let secondaryButtonLabel = ShieldConfiguration.Label(text: secondaryButtonText, color: .black)
            
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
            let subtitleLabel = ShieldConfiguration.Label(text: "Error \(error.localizedDescription)", color: .black)
            return ShieldConfiguration(backgroundColor: .bg, subtitle: subtitleLabel)
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
