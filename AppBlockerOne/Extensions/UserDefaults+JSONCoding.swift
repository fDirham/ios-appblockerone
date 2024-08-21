//
//  UserDefaults+JSONCoding.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/21/24.
//

import Foundation

extension UserDefaults {
    func setObj<T: Codable>(_ inObj: T, forKey: String) throws {
        let saveVal: String = try encodeJSONObj(inObj)
        self.set(saveVal, forKey: forKey)
    }
    
    func getObj<T: Codable>(forKey: String) throws -> T? {
        guard let rawVal = self.string(forKey: forKey) else {
            return nil
        }
        
        let toReturn: T = try decodeJSONObj(rawVal)
        return toReturn
    }
}
