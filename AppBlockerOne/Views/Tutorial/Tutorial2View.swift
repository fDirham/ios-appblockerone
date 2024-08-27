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
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.splashPond)
                    .offset(y: 100)
                    .opacity(tutorialOpacity)
                Spacer()
            }
            .onAppear {
                // TODO: Set to non tutorial
                withAnimation {
                    tutorialOpacity = 1
                }
            }
            .task {
                do {
                    let seconds: Double = 3
                    try await Task.sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))
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
