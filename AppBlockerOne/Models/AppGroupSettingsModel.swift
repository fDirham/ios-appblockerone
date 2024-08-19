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
import DeviceActivity

@Observable class AppGroupSettingsModel {
    var coreDataContext: NSManagedObjectContext
    
    var groupName: String = ""
    var faSelection: FamilyActivitySelection = FamilyActivitySelection()
    var s_blockingEnabled: Bool = true
    var s_strictBlock: Bool = false
    var s_maxOpensPerDay = 6
    var s_durationPerOpenM = 30
    var s_openMethod: OpenMethods = .Tap5
    var s_blockSchedule_start: Int = 0
    var s_blockSchedule_end: Int = 2359
    
    var cdObj: AppGroup? = nil
    
    private static let RANGE_MAX_OPENS_PER_DAY = 1...100
    private static let RANGE_DURATION_PER_OPEN_M = 1...300

    init(coreDataContext: NSManagedObjectContext){
        self.coreDataContext = coreDataContext
    }
    
    init(coreDataContext: NSManagedObjectContext, cdObj: AppGroup){
        self.coreDataContext = coreDataContext
        self.cdObj = cdObj
        try! _syncSelfWithCDObj()
    }

    private func _createNewCDObj() throws {
        let newItem = AppGroup(context: coreDataContext)
        newItem.timestamp = Date()
        newItem.id = UUID()
        // TODO: Better color handling
        newItem.groupColor = ["blue", "red", "green", "orange"].randomElement()!
        
        self.cdObj = newItem
    }
    
    private func _syncCDObjWithSelf() throws {
        if cdObj != nil{
            let faString = try encodeJSONObj(self.faSelection)
            cdObj!.faSelection = faString
            cdObj!.groupName = self.groupName
            cdObj!.s_blockSchedule_start = Int16(self.s_blockSchedule_start)
            cdObj!.s_blockSchedule_end = Int16(self.s_blockSchedule_end)
            cdObj!.s_openMethod = self.s_openMethod.rawValue
            cdObj!.s_strictBlock = self.s_strictBlock
            cdObj!.s_maxOpensPerDay = Int16(self.s_maxOpensPerDay)
            cdObj!.s_durationPerOpenM = Int16(self.s_durationPerOpenM)
        }
    }
    
    private func _syncSelfWithCDObj() throws {
        if cdObj != nil {
            self.groupName = cdObj!.groupName ?? ""
            if let faSelection: FamilyActivitySelection = try? decodeJSONObj(cdObj!.faSelection ?? "") {
                self.faSelection = faSelection
            }
            self.s_blockingEnabled = cdObj!.s_blockingEnabled
            self.s_strictBlock = cdObj!.s_strictBlock
            self.s_maxOpensPerDay = Int(cdObj!.s_maxOpensPerDay)
            self.s_durationPerOpenM = Int(cdObj!.s_durationPerOpenM)
            self.s_openMethod = OpenMethods(rawValue: cdObj!.s_openMethod ?? OpenMethods.Tap5.rawValue) ?? OpenMethods.Tap5
            self.s_blockSchedule_start = Int(cdObj!.s_blockSchedule_start)
            self.s_blockSchedule_end = Int(cdObj!.s_blockSchedule_end)
        }
    }
    
    func rollbackLocalChanges() {
        try! _syncSelfWithCDObj()
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
            try _createNewCDObj()
            try _syncCDObjWithSelf()
            try coreDataContext.save()
            try _onSave()
        } catch {
            let nsError = error as NSError
            Logger().error("Unresolved error \(nsError), \(nsError.userInfo)")
            return (false, "Failed to save, please try again later")
        }

        return (true, nil)
    }
    
    func handleSaveEdit() -> (Bool, String?) {
        // Validate
        let errorMsg = _validateSettings()
        if errorMsg != nil {
            return (false, errorMsg)
        }
        
        // Save
        do {
            try _beforeSaveSync()
            try _syncCDObjWithSelf()
            try coreDataContext.save()
            try _onSave()
        } catch {
            let nsError = error as NSError
            Logger().error("Unresolved error \(nsError), \(nsError.userInfo)")
            return (false, "Failed to save, please try again later")
        }

        return (true, nil)
    }
    
    private func _beforeSaveSync() throws {
        // Unblock apps in cdo
        let cdoFa: FamilyActivitySelection = try decodeJSONObj(cdObj!.faSelection!)
        try unblockApps(faSelection: cdoFa)
    }
    
    private func _onSave() throws {
        if cdObj == nil{
            fatalError("Trying to save app settings with empty cdObj")
        }
        
        print("Triggering on save")
        
        let center = DeviceActivityCenter()
        let saveName = "ms_" + cdObj!.id!.uuidString
        
        // Save in user defaults
        let saveVal = try encodeJSONObj(faSelection)
        UserDefaults(suiteName: "group.appblockerone")!.set(saveVal, forKey: saveName)
        
        // Schedule
        let deviceActivityName = DeviceActivityName(saveName)
        let startComponents = _getTimeSettingComponents(s_blockSchedule_start)
        let endComponents = _getTimeSettingComponents(s_blockSchedule_end)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startComponents.hours, minute: startComponents.minutes), intervalEnd: DateComponents(hour: endComponents.hours, minute: endComponents.minutes), repeats: true
        )
        
        // Block right away
        try blockApps(faSelection: faSelection)
        
        // Stop current then start again
        center.stopMonitoring([deviceActivityName])
        try center.startMonitoring(deviceActivityName, during: schedule)
    }
    
    private func _validateSettings() -> String? {
        if groupName == "" {
            return "Group needs a name"
        }
        if groupName.count > 15 {
            return "Group name too long"
        }
        let emptyFa = faSelection.applicationTokens.isEmpty && faSelection.webDomainTokens.isEmpty && faSelection.categoryTokens.isEmpty
        if emptyFa {
            return "Please select one or more apps for this group"
        }
        
        return nil
    }
    
    private func _getTimeSettingComponents(_ settingsVal: Int) -> (hours: Int, minutes: Int) {
        let strVal = "0000\(settingsVal)".suffix(4)
        let hoursVal = Int(strVal.prefix(2)) ?? 0
        let minutesVal = Int(strVal.suffix(2)) ?? 0
        return (hours: hoursVal, minutes: minutesVal)
    }
}
