//
//  Tutorial0View.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import SwiftUI

struct Tutorial0View: View {
    @Environment(TutorialConfig.self) private var tutorialConfig
    @State private var tutorialOpacity: Double = 0

    var body: some View {
        ZStack {
            HomeView()
            VStack{
                Text("To start blocking apps, tap the + icon")
                    .tutorialText()
                    .offset(y: 100)
                    .opacity(tutorialOpacity)
                Spacer()
            }
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                withAnimation {
                    tutorialOpacity = 1
                }
            }
        }
    }
}

struct Tutorial0View_Preview: PreviewProvider {
    struct Container: View {
        @State private var tutorialConfig = TutorialConfig(isTutorial: true)
        @State private var navManager = NavManager()
        
        var body: some View {
            NavStackView {
                Tutorial0View()
            }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(tutorialConfig)
            .environment(navManager)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
