//
//  ReusableStyles.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/14/24.
//

import SwiftUI

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
}
