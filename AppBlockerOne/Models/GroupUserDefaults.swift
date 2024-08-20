//
//  UserDefaultManager.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/20/24.
//

import Foundation

class GroupUserDefaults: UserDefaults {
    static private let SUITE_NAME = "group.appblockerone"
    
    init(){
        super.init(suiteName: GroupUserDefaults.SUITE_NAME)!
    }
}
