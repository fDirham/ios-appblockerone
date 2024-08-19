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
        let subtitle = ShieldConfiguration.Label(text: "From app \(application.localizedDisplayName ?? "?")", color: .black)
        let toReturn = ShieldConfiguration(backgroundColor: .white, subtitle: subtitle)
        
        return toReturn
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
