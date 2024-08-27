//
//  ContentView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TutorialView()
    }
}

struct ContentView_Preview: PreviewProvider {
    struct Container: View {
        @State private var tutorialConfig = TutorialConfig()
        
        var body: some View {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environment(tutorialConfig)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
