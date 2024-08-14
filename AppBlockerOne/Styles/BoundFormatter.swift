//
//  BoundFormatter.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI

class BoundFormatter: Formatter {
    var max: Int = 0
    var min: Int = 0
    
    func clamp(with value: Int, min: Int, max: Int) -> Int{
        guard value <= max else {
            return max
        }
        
        guard value >= min else {
            return min
        }
        
        return value
    }

    func setMax(_ max: Int) {
        self.max = max
    }
    func setMin(_ min: Int) {
        self.min = min
    }
    
    override func string(for obj: Any?) -> String? {
        guard let number = obj as? Int else {
            return String(min)
        }
        return String(number)
        
    }

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {

        guard let number = Int(string) else {
            return false
        }
        
        obj?.pointee = clamp(with: number, min: self.min, max: self.max) as AnyObject
        
        return true
    }
    
}
