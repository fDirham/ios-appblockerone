//
//  Tutorial0View.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import SwiftUI

struct Tutorial1View: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(TutorialConfig.self) private var tutorialConfig
    @State private var tutorialOpacity: Double = 0
    
    var body: some View {
        ZStack {
            NewAppGroupView(coreDataContext: viewContext)
                .onTapGesture {
                    withAnimation {
                        tutorialOpacity = 0
                    }
                }
            VStack{
                Text("Fill in this form and tap save when done")
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.splashPond)
                    .offset(y: 40)
                    .opacity(tutorialOpacity)
                Spacer()
            }
            .onAppear {
                withAnimation {
                    tutorialOpacity = 1
                }
            }
        }
    }
}

struct Tutorial1View_Preview: PreviewProvider {
    struct Container: View {
        @State private var tutorialConfig = TutorialConfig(isTutorial: true)
        @State private var navManager = NavManager()
        
        var body: some View {
            NavStackView {
                Tutorial1View()
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
