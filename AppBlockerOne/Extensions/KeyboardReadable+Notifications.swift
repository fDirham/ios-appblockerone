//
//  KeyboardReadable+Extensions.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/14/24.
// https://stackoverflow.com/questions/65784294/how-to-detect-if-keyboard-is-present-in-swiftui
//  So we can detect keyboard presses

import Combine
import UIKit


/// Publisher to read keyboard changes.
protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}
