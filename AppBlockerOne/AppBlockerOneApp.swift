//
//  AppBlockerOneApp.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI
import FamilyControls

@main
struct AppBlockerOneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .foregroundStyle(.fg)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .task {
                    let center = UNUserNotificationCenter.current()
                    do
                    {
                        try await center.requestAuthorization(options: [.alert, .sound, .badge])
                        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                    }
                    catch {
                        fatalError(error.localizedDescription)
                    }
                }
        }
    }
}
