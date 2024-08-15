//
//  AppGroupSettingsModel.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/14/24.
//

import Foundation
import FamilyControls

@Observable class AppGroupSettingsModel {
    var groupName: String = ""
    var faSelection: FamilyActivitySelection = FamilyActivitySelection()
    var s_blockingEnabled: Bool = true
    var s_strictBlock: Bool = false
    var s_maxOpensPerDay = 6
    var s_durationPerOpenM = 5
    var s_openMethod: OpenMethods = .Tap5
    var s_blockSchedule_start = 0
    var s_blockSchedule_end = 2359
    
    private static let RANGE_MAX_OPENS_PER_DAY = 1...100
    private static let RANGE_DURATION_PER_OPEN_M = 1...300

    
    func handleKeyboardClose(){
        // Check max and mins
        s_maxOpensPerDay = s_maxOpensPerDay.clamped(to: Self.RANGE_MAX_OPENS_PER_DAY)
        s_durationPerOpenM = s_durationPerOpenM.clamped(to: Self.RANGE_DURATION_PER_OPEN_M)
    }
    
    func handleSaveNew() -> (Bool, String?){
        // Validate
        let errorMsg = _validateSettings()
        if errorMsg != nil {
            return (false, errorMsg)
        }
        
        // Save
        // TODO
        return (true, nil)
    }
    
    func _validateSettings() -> String? {
        if groupName == "" {
            return "Group needs a name"
        }
        let emptyFa = faSelection.applicationTokens.isEmpty && faSelection.webDomainTokens.isEmpty && faSelection.categoryTokens.isEmpty
        if emptyFa {
            return "Please select one or more apps for this group"
        }
        
        return nil
    }
}
