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

struct PillButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(minWidth: 260)
            .background(Color.accentColor)
            .clipShape(Capsule())
            .foregroundStyle(.fg)
            .fontWeight(.semibold)
    }
}

struct PillButtonMini: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 6)
            .padding(.horizontal, 22)
            .background(Color.accentColor)
            .clipShape(Capsule())
            .foregroundStyle(.fg)
            .fontWeight(.semibold)
    }
}

struct HelpTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .padding(.bottom, 2)
            .fontWeight(.bold)
    }
}

struct HelpText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.bottom, 16)
    }
}

struct TutorialText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .padding(.vertical, 6)
            .padding(.horizontal, 22)
            .background(Color.splashPond)
            .clipShape(Capsule())
            .foregroundStyle(.fg)
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
    
    public func pillButton() -> some View {
        modifier(PillButton())
    }
    
    public func pillButtonMini() -> some View {
        modifier(PillButtonMini())
    }

    public func helpTitle() -> some View {
        modifier(HelpTitle())
    }
    
    public func helpText() -> some View {
        modifier(HelpText())
    }
    
    public func tutorialText() -> some View {
        modifier(TutorialText())
    }
}
