//
//  SettingsView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/29/24.
//

import SwiftUI
import ObservableUserDefault

@Observable class SettingsViewModel {
    @ObservableUserDefault(.init(key: DEFAULT_KEY_NOTIFICATIONS_ON, defaultValue: true, store: .groupUserDefaults))
    @ObservationIgnored
    var notificationsOn: Bool
}

struct SettingsView: View {
    @State private var svm = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            Color.bg
                .ignoresSafeArea()
                .overlay {
                    ScrollView {
                        VStack(spacing: 35) {
                            SettingGroupView("General", spacing: 12) {
                                BooleanSettingsView("Notifications on", value: $svm.notificationsOn.animation(Animation.smooth(duration: 0.4)))
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Settings")
                }
        }
    }
}

#Preview {
    SettingsView()
}
