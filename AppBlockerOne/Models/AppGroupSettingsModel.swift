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
import ManagedSettings

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
            cdObj!.s_blockingEnabled = self.s_blockingEnabled
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
        return _handleSave()
    }
    
    func handleSaveEdit() -> (Bool, String?) {
        return _handleSave()
    }
    
    private func _handleSave() -> (Bool, String?) {
        do {
            // Split tokens to find what has been modified
            let modifiedTokenBatch: AddRemoveTokenBatch = try _splitTokensBeforeSync()
            
            // Validate
            let errorMsg = _validateSettings(modifiedTokenBatch: modifiedTokenBatch)
            if errorMsg != nil {
                return (false, errorMsg)
            }
                
            if cdObj == nil {
                try _createNewCDObj()
            }
            
            let isJustEnabled = _isJustEnabled()
            
            // We are disabling everything here
            if !s_blockingEnabled {
                // Remove from defaults entirely
                let groupId: UUID = cdObj!.id!
                let sKey = getScheduleDefaultKey(groupId)!
                let gsKey = getGroupShieldDefaultKey(groupId)!
                let tbKey = getTempBlockDefaultKey(groupId)!
                
                let ud = GroupUserDefaults()
                ud.removeObject(forKey: sKey)
                ud.removeObject(forKey: gsKey)
                ud.removeObject(forKey: tbKey)
                
                // Remove blocked items
                let cdoFa: FamilyActivitySelection = try decodeJSONObj(cdObj!.faSelection!)
                let removeAllTokenBatch = (added: TokenSplit(), removed: TokenSplit(appTokens: cdoFa.applicationTokens, webTokens: cdoFa.webDomainTokens, catTokens: cdoFa.categoryTokens))
                try _addAndRemoveBlockedItemTokens(arTokenBatch: removeAllTokenBatch)
                
                // Unblock all apps
                try unblockApps(faSelection: cdoFa)

                // Make sure it's not monitored in device activity
                let center = DeviceActivityCenter()
                let sActivityName = DeviceActivityName(sKey)
                let tbActivityName = DeviceActivityName(tbKey)
                center.stopMonitoring([sActivityName, tbActivityName])
                
                // Sync with core data
                try _syncCDObjWithSelf()
                try coreDataContext.save()
                
                return (true, nil)
            }
            
            
            // Add to blocked items + block unblock immediately
            if isJustEnabled {
                let added = TokenSplit(
                    appTokens: faSelection.applicationTokens,
                    webTokens: faSelection.webDomainTokens,
                    catTokens: faSelection.categoryTokens
                )
                let addAllTokenBatch: AddRemoveTokenBatch = (added: added, removed: TokenSplit())
                try _addAndRemoveBlockedItemTokens(arTokenBatch: addAllTokenBatch)
                try _onSaveBlockUnblock(arTokenBatch: addAllTokenBatch)
            }
            else{
                try _addAndRemoveBlockedItemTokens(arTokenBatch: modifiedTokenBatch)
                try _onSaveBlockUnblock(arTokenBatch: modifiedTokenBatch)
            }
            
            try _syncCDObjWithSelf()
            try coreDataContext.save()

            // Save as schedule default
            let ud = GroupUserDefaults()
            let scheduleDefault = ScheduleDefault(faSelection: faSelection)
            let sKey = getScheduleDefaultKey(cdObj!.id!)!
            try ud.setObj(scheduleDefault, forKey: sKey)
            
            // Save as group shield default
            let gsKey = getGroupShieldDefaultKey(cdObj!.id!)!
            let gsToSave = GroupShieldDefault(groupName: cdObj!.groupName!)
            try ud.setObj(gsToSave, forKey: gsKey)

            // Schedule in device activity
            let center = DeviceActivityCenter()
            let startComponents = _getTimeSettingComponents(s_blockSchedule_start)
            let endComponents = _getTimeSettingComponents(s_blockSchedule_end)
            
            let schedule = DeviceActivitySchedule(
                intervalStart: DateComponents(hour: startComponents.hours, minute: startComponents.minutes), intervalEnd: DateComponents(hour: endComponents.hours, minute: endComponents.minutes), repeats: true
            )
            
            // Start monitoring
            let deviceActivityName = DeviceActivityName(sKey)
            try center.startMonitoring(deviceActivityName, during: schedule) // NOTE this overrides previously scheduled so we should be good
            
        } catch {
            let nsError = error as NSError
            Logger().error("Unresolved error \(nsError), \(nsError.userInfo)")
            return (false, "Failed to save, please try again later")
        }

        return (true, nil)
    }
    
    private func _isJustEnabled() -> Bool{
        if cdObj == nil {
            return false
        }
        
        return !cdObj!.s_blockingEnabled && s_blockingEnabled
    }
    
    private func _onSaveBlockUnblock(arTokenBatch: AddRemoveTokenBatch) throws {
        // Check current time
        let currDate = Date.now
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currDate)
        let hourStr = String("0\(hour)".suffix(2))
        let minute = calendar.component(.minute, from: currDate)
        let minStr = String("0\(minute)".suffix(2))
        if let currTimeSetting = Int(hourStr + minStr) {
            let shouldBlock = s_blockSchedule_start <= currTimeSetting && currTimeSetting <= s_blockSchedule_end
            
            if shouldBlock {
                let added = arTokenBatch.added
                try blockApps(appTokens: added.appTokens, webTokens: added.webTokens, catTokens: added.catTokens)
            }
        }
        
        let removed = arTokenBatch.removed
        try unblockApps(appTokens: removed.appTokens, webTokens: removed.webTokens, catTokens: removed.catTokens)
    }
    
    private func _addAndRemoveBlockedItemTokens(arTokenBatch: AddRemoveTokenBatch) throws {
        if cdObj == nil {
            throw "No cdObj instantiated"
        }
        
        // Add
        func addTokenSet<T>(_ tokenSet: Set<Token<T>>) throws {
            tokenSet.forEach{token in
                // Add in user defaults
                if let userDefaultKey = getBlockedItemDefaultKey(token) {
                    GroupUserDefaults().set(cdObj!.id!.uuidString, forKey: userDefaultKey)
                }
            }
        }
        
        let added = arTokenBatch.added
        try addTokenSet(added.appTokens)
        try addTokenSet(added.webTokens)
        try addTokenSet(added.catTokens)
        
        // Remove
        func removeTokenSet<T>(_ tokenSet: Set<Token<T>>) throws {
            tokenSet.forEach{token in
                if let userDefaultKey = getBlockedItemDefaultKey(token) {
                    GroupUserDefaults().removeObject(forKey: userDefaultKey)
                }
            }
        }
        
        let removed = arTokenBatch.removed
        try removeTokenSet(removed.appTokens)
        try removeTokenSet(removed.webTokens)
        try removeTokenSet(removed.catTokens)
    }
    
    private typealias AddRemoveTokenBatch = (added: TokenSplit, removed: TokenSplit)
    private struct TokenSplit {
        var appTokens: Set<ApplicationToken>
        var webTokens: Set<WebDomainToken>
        var catTokens: Set<ActivityCategoryToken>
        
        init(appTokens: Set<ApplicationToken> = Set(), webTokens: Set<WebDomainToken> = Set(), catTokens: Set<ActivityCategoryToken> = Set()) {
            self.appTokens = appTokens
            self.webTokens = webTokens
            self.catTokens = catTokens
        }
    }
    
    private func _splitTokensBeforeSync() throws -> AddRemoveTokenBatch{
        if cdObj == nil {
            return (added: TokenSplit(), removed: TokenSplit())
        }
        
        let cdoFa: FamilyActivitySelection = try decodeJSONObj(cdObj!.faSelection!)
        
        // See what has been deleted
        let deletedAppTokens = cdoFa.applicationTokens.subtracting(faSelection.applicationTokens)
        let deletedWebTokens = cdoFa.webDomainTokens.subtracting(faSelection.webDomainTokens)
        let deletedCatTokens = cdoFa.categoryTokens.subtracting(faSelection.categoryTokens)
        
        // See what has been added
        let addedAppTokens = faSelection.applicationTokens.subtracting(cdoFa.applicationTokens)
        let addedWebTokens = faSelection.webDomainTokens.subtracting(cdoFa.webDomainTokens)
        let addedCatTokens = faSelection.categoryTokens.subtracting(cdoFa.categoryTokens)
        
        return (added: TokenSplit(
            appTokens: addedAppTokens,
            webTokens: addedWebTokens,
            catTokens: addedCatTokens
        ), removed: TokenSplit(
            appTokens: deletedAppTokens,
            webTokens: deletedWebTokens,
            catTokens: deletedCatTokens
        ))
    }

    private func _validateSettings(modifiedTokenBatch: AddRemoveTokenBatch) -> String? {
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
        
        // Validate no duplicates
        do {
            func dupeCheckTokens<T>(_ tokenSet: Set<Token<T>>) throws -> String? {
                for token in tokenSet {
                    if let udKey = getBlockedItemDefaultKey(token){
                        let res = GroupUserDefaults().string(forKey: udKey)
                        if res != nil {
                            return "One of your apps is already managed by another group."
                        }
                    }
                }
                return nil
            }
            
            let addedTokenSplit = modifiedTokenBatch.added
            let dupeErrApp = try dupeCheckTokens(addedTokenSplit.appTokens)
            if dupeErrApp != nil {
                return dupeErrApp
            }
            let dupeErrWeb = try dupeCheckTokens(addedTokenSplit.webTokens)
            if dupeErrWeb != nil {
                return dupeErrWeb
            }
            let dupeErrCat = try dupeCheckTokens(addedTokenSplit.catTokens)
            if dupeErrCat != nil {
                return dupeErrCat
            }
        }
        catch {
            return "Something went wrong checking duplicates \(error.localizedDescription)"
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
