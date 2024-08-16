//
//  ReusableStyles.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/14/24.
//

import SwiftUI

struct RoundedBG: ViewModifier {
    var fill: Color
    var cornerRadius: CGFloat = 5
    
    init(fill: Color, cornerRadius: CGFloat?) {
        self.fill = fill
        if cornerRadius != nil {
            self.cornerRadius = cornerRadius!
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(fill))
    }
}

struct SettingBlockBG: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.interactable))
    }
}

extension View {
    public func settingBlockBG ()-> some View {
        modifier(SettingBlockBG())
    }
    
    public func roundedBG (fill: Color) -> some View {
        modifier(RoundedBG(fill: fill, cornerRadius: nil))
    }
    
    public func roundedBG (fill: Color, cornerRadius: CGFloat) -> some View {
        modifier(RoundedBG(fill: fill, cornerRadius: cornerRadius))
    }
}
