//
//  iosMainAppUnitTests.swift
//  iosMainAppUnitTests
//
//  Created by Fajar Dirham on 8/22/24.
//

import XCTest

final class UserDefaultHelpersTest: XCTestCase {
    func testGetMainContentsOfUserDefaultKey() throws {
        // 1 - Arrange
        let groupId = UUID()
        let udKey = getScheduleDefaultKey(groupId)!
        
        // 2 - Act
        let mainContent = getMainContentOfUserDefaultKey(udKey: udKey)
        
        // 3 - Assert
        XCTAssertEqual(groupId.uuidString, mainContent)
    }
}
