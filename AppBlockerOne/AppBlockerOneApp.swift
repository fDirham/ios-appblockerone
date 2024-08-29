//
//  AppBlockerOneApp.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI

@main
struct AppBlockerOneApp: App {
    @State private var tutorialConfig = TutorialConfig(isTutorial: true)
    @State private var navManager = NavManager()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .foregroundStyle(.fg)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(tutorialConfig)
                .environment(navManager)
        }
    }
}
