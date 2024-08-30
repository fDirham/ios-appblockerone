//
//  Tutorial0View.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import SwiftUI

struct Tutorial2View: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(TutorialConfig.self) private var tutorialConfig
    @State private var tutorialOpacity: Double = 0
    
    var body: some View {
        ZStack {
            HomeView()
            VStack{
                Text("Enjoy :)")
                    .tutorialText()
                    .offset(y: 100)
                    .opacity(tutorialOpacity)
                Spacer()
            }
            .toolbar(.visible, for: .tabBar)
            .onAppear {
                if !tutorialConfig.isTutorial{
                    return
                }
                
                tutorialConfig.isTutorial = false
                
                withAnimation {
                    tutorialOpacity = 1
                }
                
                let ud = GroupUserDefaults()
                ud.set(true, forKey: DEFAULT_KEY_TUTORIAL_DONE)
            }
            .task {
                do {
                    try await waitForS(seconds: 3)
                    withAnimation{
                        tutorialOpacity = 0
                    }
                }
                catch {
                    withAnimation{
                        tutorialOpacity = 0
                    }
                }
            }
        }
    }
}

struct Tutorial2View_Preview: PreviewProvider {
    struct Container: View {
        @State private var tutorialConfig = TutorialConfig(isTutorial: true)
        @State private var navManager = NavManager()
        
        var body: some View {
            NavStackView {
                Tutorial2View()
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
