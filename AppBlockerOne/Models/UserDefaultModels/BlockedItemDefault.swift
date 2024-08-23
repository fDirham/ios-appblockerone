//
//  BlockedItemDefault.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/23/24.
//

import Foundation
import ManagedSettings

struct BlockedItemDefault: Codable {
    var groupId: String
    var appToken: ApplicationToken?
    var webToken: WebDomainToken?
    var catToken: ActivityCategoryToken?
    
    init(groupId: String, appToken: ApplicationToken? = nil, webToken: WebDomainToken? = nil, catToken: ActivityCategoryToken? = nil) {
        self.groupId = groupId
        self.appToken = appToken
        self.webToken = webToken
        self.catToken = catToken
    }
}
