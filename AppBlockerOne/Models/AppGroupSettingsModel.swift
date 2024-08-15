//
//  AppGroupSettingsModel.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/14/24.
//

import Foundation
import FamilyControls
import CoreData
import OSLog

@Observable class AppGroupSettingsModel {
    var coreDataContext: NSManagedObjectContext
    
    var groupName: String = ""
    var faSelection: FamilyActivitySelection = FamilyActivitySelection()
    var s_blockingEnabled: Bool = true
    var s_strictBlock: Bool = false
    var s_maxOpensPerDay = 6
    var s_durationPerOpenM = 5
    var s_openMethod: OpenMethods = .Tap5
    var s_blockSchedule_start: Int = 0
    var s_blockSchedule_end: Int = 2359
    
    private static let RANGE_MAX_OPENS_PER_DAY = 1...100
    private static let RANGE_DURATION_PER_OPEN_M = 1...300

    init(coreDataContext: NSManagedObjectContext){
        self.coreDataContext = coreDataContext
    }
    
    static func createNewCDObj(inObj: AppGroupSettingsModel) throws -> AppGroup{
        let newItem = AppGroup(context: inObj.coreDataContext)
        newItem.timestamp = Date()
        
        let faString = try encodeJSONObj(inObj.faSelection)
        newItem.faSelection = faString
        
        newItem.id = UUID()
        newItem.groupName = inObj.groupName
        // TODO: Better color handling
        newItem.groupColor = ["blue", "red", "green", "orange"].randomElement()!
        newItem.s_blockSchedule_start = Int16(inObj.s_blockSchedule_start)
        newItem.s_blockSchedule_end = Int16(inObj.s_blockSchedule_end)
        newItem.s_openMethod = inObj.s_openMethod.rawValue
        newItem.s_strictBlock = inObj.s_strictBlock
        newItem.s_maxOpensPerDay = Int16(inObj.s_maxOpensPerDay)
        newItem.s_durationPerOpenM = Int16(inObj.s_durationPerOpenM)
        
        return newItem
    }
    
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
        do {
            var _ = try AppGroupSettingsModel.createNewCDObj(inObj: self)
            try coreDataContext.save()
        } catch {
            let nsError = error as NSError
            Logger().error("Unresolved error \(nsError), \(nsError.userInfo)")
            return (false, "Failed to save, please try again later")
        }

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
