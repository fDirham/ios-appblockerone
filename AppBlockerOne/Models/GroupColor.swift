//
//  GroupColor.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import Foundation
import SwiftUI


func getColor(colorString: String) -> Color {
    switch colorString {
    case "red":
        return .red
    case "blue":
        return .blue
    case "orange":
        return .orange
    case "green":
        return .green
    case "yellow":
        return .yellow
    default:
        return .black
    }
}
