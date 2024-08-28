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
    var s_blockingEnabled: Bool = true // Always set to true lol
    var s_strictBlock: Bool = false
    var s_maxOpensPerDay = 6
    var s_durationPerOpenM = 30
    var s_openMethod: OpenMethods = .Tap5
    var s_blockSchedule_start: Int = 0
    var s_blockSchedule_end: Int = 2359
    
    var cdObj: AppGroup? = nil
    
    private static let RANGE_MAX_OPENS_PER_DAY = 1...100
    private static let RANGE_DURATION_PER_OPEN_M = 15...300

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
    
    func handleSaveNew() -> (Bool, SettingsError?){
        return _handleSave()
    }
    
    func handleSaveEdit() -> (Bool, SettingsError?) {
        return _handleSave()
    }
    
    func handleDelete() -> (Bool, String?){
        guard let cdObj = cdObj else {
            return (true, nil)
        }
        
        do {
            try _onBlockingDisabledSave()
            
            // Delete self
            coreDataContext.delete(cdObj)
            try coreDataContext.save()
        }
        catch {
            return (false, error.localizedDescription)
        }
        // Update blocked group counter
        let ud = GroupUserDefaults()
        let currGroupCount = ud.integer(forKey: DEFAULT_KEY_BLOCKED_GROUP_COUNTER)
        let newGroupCount = currGroupCount - 1
        ud.set(newGroupCount, forKey: DEFAULT_KEY_BLOCKED_GROUP_COUNTER)
        
        // Update blocked item counter
        let currItemCount = ud.integer(forKey: DEFAULT_KEY_BLOCKED_ITEM_COUNTER)
        let toDeleteItemCount = faSelection.applicationTokens.count + faSelection.categoryTokens.count + faSelection.webDomainTokens.count
        let newItemCount = currItemCount - toDeleteItemCount
        ud.set(newItemCount, forKey: DEFAULT_KEY_BLOCKED_ITEM_COUNTER)
        
        return (true, nil)
    }
    
    private func _handleSave() -> (Bool, SettingsError?) {
        handleKeyboardClose()
        
        do {
            // Split tokens to find what has been modified
            let modifiedTokenBatch: AddRemoveTokenBatch = try _getModifiedTokensBeforeSync()
            
            // Validate
            let settingsError = _validateSettings(modifiedTokenBatch: modifiedTokenBatch)
            if settingsError != nil {
                return (false, settingsError)
            }
            
            let isNew = cdObj == nil
            if isNew {
                try _createNewCDObj()
            }
            
            // Remnant of old code from when we could disable
//            let isJustEnabled = !(cdObj!.s_blockingEnabled) && s_blockingEnabled

            if !s_blockingEnabled {
                // We are disabling everything here
                try _onBlockingDisabledSave()
            }
            
            // Add to blocked items + block unblock immediately
            try _addAndRemoveBlockedItemTokens(arTokenBatch: modifiedTokenBatch)
            try _onSaveBlockUnblock()

            try _syncCDObjWithSelf()
            try coreDataContext.save()

            // Save as schedule default
            let ud = GroupUserDefaults()
            let scheduleDefault = ScheduleDefault(faSelection: faSelection, groupName: groupName)
            let sKey = getScheduleDefaultKey(cdObj!.id!)!
            try ud.setObj(scheduleDefault, forKey: sKey)
            
            // Save as group shield default
            let gsKey = getGroupShieldDefaultKey(cdObj!.id!)!
            let gsToSave = GroupShieldDefault(
                groupName: cdObj!.groupName!, 
                strictBlock: s_strictBlock,
                durationPerOpenM: s_durationPerOpenM,
                maxOpensPerDay: s_maxOpensPerDay,
                maxTaps: s_openMethod == OpenMethods.TapOnce ? 1 : 5 // TODO: Handle more unblock methods
            )
            try ud.setObj(gsToSave, forKey: gsKey)

            // Schedule in device activity
            let center = DeviceActivityCenter()
            let startComponents = _getTimeSettingComponents(s_blockSchedule_start)
            let endComponents = _getTimeSettingComponents(s_blockSchedule_end)
            
            let schedule = DeviceActivitySchedule(
                intervalStart: DateComponents(hour: startComponents.hours, minute: startComponents.minutes), intervalEnd: DateComponents(hour: endComponents.hours, minute: endComponents.minutes), repeats: true
            )
            
            // Start monitoring
            let deviceActivityName = getBlockScheduleDAName(groupId: cdObj!.id!)
            try center.startMonitoring(deviceActivityName, during: schedule) // NOTE this overrides previously scheduled so we should be good
            
            // Update blocked group counter
            if isNew {
                let currGroupCount = ud.integer(forKey: DEFAULT_KEY_BLOCKED_GROUP_COUNTER)
                let newGroupCount = currGroupCount + 1
                ud.set(newGroupCount, forKey: DEFAULT_KEY_BLOCKED_GROUP_COUNTER)
            }
            
            // Update blocked item counter
            let currItemCount = ud.integer(forKey: DEFAULT_KEY_BLOCKED_ITEM_COUNTER)
            let netItemsAdded = _getNetItemsAdded(tokenBatch: modifiedTokenBatch)
            let newItemCount = currItemCount + netItemsAdded
            ud.set(newItemCount, forKey: DEFAULT_KEY_BLOCKED_ITEM_COUNTER)
        } catch {
            let nsError = error as NSError
            Logger().error("Unresolved error \(nsError), \(nsError.userInfo)")
            return (false, SettingsError(alertMsg: "Unresolveed error \(error.localizedDescription)"))
        }

        return (true, nil)
    }
    
    private func _onBlockingDisabledSave() throws{
        let groupId: UUID = cdObj!.id!
        let cdoFa: FamilyActivitySelection = try decodeJSONObj(cdObj!.faSelection!)
        let faSelectionTokenSplit = TokenSplit(appTokens: cdoFa.applicationTokens, webTokens: cdoFa.webDomainTokens, catTokens: cdoFa.categoryTokens)

        // Get UD keys
        let ud = GroupUserDefaults()
        guard let sKey = getScheduleDefaultKey(groupId) else { throw "Failed to get sKey key" }
        guard let sefKey = getScheduleEndFlagDefaultKey(groupId) else { throw "Failed to get sefKey key" }
        guard let gsKey = getGroupShieldDefaultKey(groupId) else { throw "Failed to get gsKey key" }

        // Delete user defaults
        ud.removeObject(forKey: sKey)
        ud.removeObject(forKey: sefKey)
        ud.removeObject(forKey: gsKey)
        
        // Delete shield memory defaults
        try _removeAllShieldMemoryDefaults(tokenSplit: faSelectionTokenSplit)

        // Delete blocked items
        let removeAllTokenBatch = (added: TokenSplit(), removed: faSelectionTokenSplit)
        try _addAndRemoveBlockedItemTokens(arTokenBatch: removeAllTokenBatch)
        
        // Unblock all apps
        try unblockApps(faSelection: cdoFa)

        // Sync with core data
        try _syncCDObjWithSelf()
        try coreDataContext.save()
        

        // Stop monitoring DAM activities a few seconds after
        Task{
            try await waitForS(seconds: 3)
            
            // Stop monitoring in DAM
            let center = DeviceActivityCenter()
            let sActivityName = getBlockScheduleDAName(groupId: groupId)
            center.stopMonitoring([sActivityName])
            
            // Remove temp unblocks
            try _removeAllTempUnblockSchedules(tokenSplit: faSelectionTokenSplit)
        }
    }
    
    private func _onSaveBlockUnblock() throws {
        // Unblock all previously
        if let cdoFaRaw: String = cdObj!.faSelection {
            let cdoFa: FamilyActivitySelection = try decodeJSONObj(cdoFaRaw)
            try unblockApps(faSelection: cdoFa)
        }

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
                try blockApps(faSelection: faSelection)
            }
        }
    }
    
    private func _removeAllTempUnblockSchedules(tokenSplit: TokenSplit) throws {
        let center = DeviceActivityCenter()
        
        func removeTempUnblock<T>(tokenSet: Set<Token<T>>) throws {
            var toStopMonitoring: Array<DeviceActivityName> = []
            try tokenSet.forEach{token in
                guard let daName = getTempUnblockDAName(token: token) else {
                    throw "Can't get temp unblock DA name for token"
                }
                toStopMonitoring.append(daName)
            }
            center.stopMonitoring(toStopMonitoring)
        }
        
        try removeTempUnblock(tokenSet: tokenSplit.appTokens)
        try removeTempUnblock(tokenSet: tokenSplit.webTokens)
        try removeTempUnblock(tokenSet: tokenSplit.catTokens)
    }
    
    private func _removeAllShieldMemoryDefaults(tokenSplit: TokenSplit) throws {
        let ud = GroupUserDefaults()
        
        func removeSMDefault<T>(tokenSet: Set<Token<T>>) throws {
            try tokenSet.forEach{token in
                guard let smKey = getShieldMemoryDefaultKey(token) else {
                    throw "Can't get gs key for token"
                }
                ud.removeObject(forKey: smKey)
            }
        }
        
        try removeSMDefault(tokenSet: tokenSplit.appTokens)
        try removeSMDefault(tokenSet: tokenSplit.webTokens)
        try removeSMDefault(tokenSet: tokenSplit.catTokens)
    }

    private func _addAndRemoveBlockedItemTokens(arTokenBatch: AddRemoveTokenBatch) throws {
        if cdObj == nil {
            throw "No cdObj instantiated"
        }
        
        // Add
        func addTokenSet<T>(_ tokenSet: Set<Token<T>>) throws {
            let ud = GroupUserDefaults()
            try tokenSet.forEach{token in
                // Add in user defaults
                if let userDefaultKey = getBlockedItemDefaultKey(token) {
                    var biItem = BlockedItemDefault(groupId: cdObj!.id!.uuidString)
                    if type(of: token) == ApplicationToken.self {
                        biItem.appToken = token as? ApplicationToken
                    }
                    else if type(of: token) == WebDomainToken.self {
                        biItem.webToken = token as? WebDomainToken
                    }
                    else if type(of: token) == ActivityCategoryToken.self {
                        biItem.catToken = token as? ActivityCategoryToken
                    }
                    try ud.setObj(biItem, forKey: userDefaultKey)
                }
            }
        }
        
        let added = arTokenBatch.added
        try addTokenSet(added.appTokens)
        try addTokenSet(added.webTokens)
        try addTokenSet(added.catTokens)
        
        // Remove
        func removeTokenSet<T>(_ tokenSet: Set<Token<T>>) throws {
            let ud = GroupUserDefaults()
            tokenSet.forEach{token in
                if let userDefaultKey = getBlockedItemDefaultKey(token) {
                    ud.removeObject(forKey: userDefaultKey)
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
    
    private func _getModifiedTokensBeforeSync() throws -> AddRemoveTokenBatch{
        if cdObj == nil {
            let allAddedTokenSplit = TokenSplit (
                appTokens: faSelection.applicationTokens,
                webTokens: faSelection.webDomainTokens,
                catTokens: faSelection.categoryTokens
            )
            return (added: allAddedTokenSplit, removed: TokenSplit())
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

    private func _validateSettings(modifiedTokenBatch: AddRemoveTokenBatch) -> SettingsError? {
        let settingsError = SettingsError()
        
        if groupName == "" {
            settingsError.groupName = "Group needs a name"
        }
        if groupName.count > 15 {
            settingsError.groupName = "Group name too long"
        }
        let emptyFa = faSelection.applicationTokens.isEmpty && faSelection.webDomainTokens.isEmpty && faSelection.categoryTokens.isEmpty
        if emptyFa {
            settingsError.faSelection = "Please select one or more apps for this group"
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
                settingsError.faSelection = dupeErrApp
            }
            let dupeErrWeb = try dupeCheckTokens(addedTokenSplit.webTokens)
            if dupeErrWeb != nil {
                settingsError.faSelection = dupeErrApp
            }
            let dupeErrCat = try dupeCheckTokens(addedTokenSplit.catTokens)
            if dupeErrCat != nil {
                settingsError.faSelection = dupeErrApp
            }
            
        }
        catch {
            debugPrint("Something went wrong checking duplicates \(error.localizedDescription)")
            settingsError.faSelection = "Something went wrong checking duplicates \(error.localizedDescription)"
        }
        
        // Validate that schedules make sense
        if abs(s_blockSchedule_end - s_blockSchedule_start) < 100 {
            settingsError.schedule = "Schedule is too short, minimum is 1 hour."
        }
        
        // Validate duration per open makes sense
        if s_durationPerOpenM < 15 {
            settingsError.durationPerOpenM = "Minimum duration per open is 15 minutes."
        }
        
        // Validate max opens per day
        if !s_strictBlock && s_maxOpensPerDay < 1 {
            settingsError.maxOpensPerDay = "If strict mode is off, max opens per day needs to be at least 1"
        }
        
        
        
        // See if we hit group limit
        let MAX_GROUPS = 10
        let ud = GroupUserDefaults()
        let currGroupCount = ud.integer(forKey: DEFAULT_KEY_BLOCKED_GROUP_COUNTER)
        let groupCountDiff = currGroupCount + 1 - MAX_GROUPS
        if groupCountDiff > 0 {
            settingsError.alertMsg = "You will hit the limit of blocked groups. Delete another group to add this one."
        }
        
        // See if we hit item limit
        let MAX_ITEMS = 40
        let netItemsAdded = _getNetItemsAdded(tokenBatch: modifiedTokenBatch)
        let currItemCount = ud.integer(forKey: DEFAULT_KEY_BLOCKED_ITEM_COUNTER)
        let itemCountDiff = netItemsAdded + currItemCount - MAX_ITEMS
        if itemCountDiff > 0 {
            settingsError.alertMsg = "You will hit the limit of blocked items. Remove \(itemCountDiff) blocked apps from this group or any other group to continue."
        }
        
        if settingsError.isNotError() {
            return nil
        }
        
        if settingsError.alertMsg == nil {
            settingsError.alertMsg = "Some settings are invalid!"
        }

        return settingsError
    }
    
    private func _getNetItemsAdded(tokenBatch: AddRemoveTokenBatch) -> Int {
        let addedTokenSplit = tokenBatch.added
        let removedTokenSplit = tokenBatch.removed
        let countItemsAdded = addedTokenSplit.appTokens.count + addedTokenSplit.catTokens.count + addedTokenSplit.webTokens.count
        let countItemsRemoved = removedTokenSplit.appTokens.count + removedTokenSplit.catTokens.count + removedTokenSplit.webTokens.count
        let netItemsAdded = countItemsAdded - countItemsRemoved
        return netItemsAdded
    }

    private func _getTimeSettingComponents(_ settingsVal: Int) -> (hours: Int, minutes: Int) {
        let strVal = "0000\(settingsVal)".suffix(4)
        let hoursVal = Int(strVal.prefix(2)) ?? 0
        let minutesVal = Int(strVal.suffix(2)) ?? 0
        return (hours: hoursVal, minutes: minutesVal)
    }
}
