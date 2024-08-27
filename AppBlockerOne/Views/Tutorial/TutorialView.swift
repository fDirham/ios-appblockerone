//
//  Tutorial1.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import SwiftUI

struct TutorialView: View {
    @Environment(TutorialConfig.self) private var tutorialConfig
    
    var body: some View {
        ZStack {
            HomeView()
                .onTapGesture {
                    tutorialConfig.tutorialTapCount += 1
                }
            switch tutorialConfig.tutorialStage {
            case 0:
                Tutorial0()
            case 1:
                Tutorial1()
            case 2:
                Tutorial2()
            default:
                EmptyView()
            }
        }
    }
}

struct Tutorial0: View {
    @State private var tutorialOpacity: Double = 0
    
    var body: some View {
        VStack{
            Text("To start blocking apps, tap the + icon")
                .multilineTextAlignment(.center)
                .padding()
                .background(.splashPond)
                .offset(y: 100)
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

struct Tutorial1: View {
    @Environment(TutorialConfig.self) private var tutorialConfig
    @State private var tutorialOpacity: Double = 0
    
    var body: some View {
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
        .onChange(of: tutorialConfig.tutorialTapCount) {
            withAnimation {
                tutorialOpacity = 0
            }
        }
    }
}

struct Tutorial2: View {
    @Environment(TutorialConfig.self) private var tutorialConfig
    @State private var tutorialOpacity: Double = 0
    
    var body: some View {
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
            withAnimation {
                tutorialOpacity = 1
            }
        }
        .onChange(of: tutorialConfig.tutorialTapCount) {
            withAnimation {
                tutorialOpacity = 0
            }
        }
    }
}

struct TutorialView_Preview: PreviewProvider {
    struct Container: View {
        @State private var tutorialConfig = TutorialConfig(isTutorial: true)
        
        var body: some View {
            TutorialView()
                .environment(tutorialConfig)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
