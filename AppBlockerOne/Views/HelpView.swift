//
//  HelpView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/26/24.
//

import SwiftUI

struct HelpView: View {
    @Environment(TutorialConfig.self) private var tutorialConfig
    @Environment(NavManager.self) private var navManager
    
    var body: some View {
        Color.bg
            .ignoresSafeArea()
            .overlay {
                ScrollView {
                    VStack(alignment: .leading){
                        Text("Can i redo the tutorial?")
                            .helpTitle()
                        Button(action: {
                            tutorialConfig.isTutorial = true
                            navManager.navTo("tutorial-0")
                        }) {
                            Text("Sure!")
                                .pillButton()
                        }
                        .padding(.bottom, 16)
                        Text("What does strict block do?")
                            .helpTitle()
                        Text("It stops you from opening up the app temporarily.")
                            .helpText()
                        Text("How does scheduling work?")
                            .helpTitle()
                        Text("It determines when your apps are blocked every day. By default, it blocks your apps for 24 hours.")
                            .helpText()
                        Text("What do the temporary open settings mean?")
                            .helpTitle()
                        Text("Max opens per day = how many times you can temporarily unblock one app per day.\nDuration per open = how long you can use an app every temporary unblock.\nOpen method = how to temporarily unblock")
                            .helpText()
                        Text("What are the different open methods?")
                            .helpTitle()
                        Text("Tap once is where you tap on a button when an app is blocked to give you temporary unblock access. Tap 5 is where you need to tap the button 5 times to do so, giving you time to think.")
                            .helpText()
                        Text("How many apps can I block?")
                            .helpTitle()
                        Text("You can manage to block 40 items, items are either apps, websites, or categories. You can only make 10 groups. These limitations exist due to hardware limitations.")
                            .helpText()
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Help")
    }
}

struct HelpView_Preview: PreviewProvider {
    struct Container: View {
        @State private var tutorialConfig = TutorialConfig()
        @State private var navManager = NavManager()
        
        var body: some View {
            NavigationStack{
                HelpView()
                    .environment(tutorialConfig)
                    .environment(navManager)
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
