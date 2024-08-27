//
//  AppBlockerOneApp.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI

@main
struct AppBlockerOneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .foregroundStyle(.fg)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
