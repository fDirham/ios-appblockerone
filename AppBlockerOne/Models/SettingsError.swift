//
//  SettingsError.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/23/24.
//

import Foundation

@Observable class SettingsError {
    var groupName: String? = nil
    var faSelection: String? = nil
    var schedule: String? = nil
    var durationPerOpenM: String? = nil
    var maxOpensPerDay: String? = nil
    var alertMsg: String? = nil
    
    init(groupName: String? = nil, faSelection: String? = nil, schedule: String? = nil, durationPerOpenM: String? = nil, maxOpensPerDay: String? = nil, alertMsg: String? = nil) {
        self.groupName = groupName
        self.faSelection = faSelection
        self.schedule = schedule
        self.durationPerOpenM = durationPerOpenM
        self.maxOpensPerDay = maxOpensPerDay
        self.alertMsg = alertMsg
    }
    
    func isNotError() -> Bool{
        return groupName == nil &&
        faSelection == nil &&
        schedule == nil &&
        durationPerOpenM == nil &&
        maxOpensPerDay == nil &&
        alertMsg == nil
    }
}
