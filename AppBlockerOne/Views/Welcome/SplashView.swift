//
//  SplashView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import SwiftUI

struct SplashView: View {
    @Environment(NavManager.self) private var navManager
    
    var body: some View {
        Color.splashBg
            .ignoresSafeArea()
            .overlay {
                GeometryReader { proxy in
                    ZStack() {
                        VStack(alignment: .center) {
                            Spacer()
                                .frame(height: proxy.size.height * 1)
                            Circle()
                                .fill(.splashPond)
                                .frame(width: 2 * proxy.size.width, height: 2 * proxy.size.width)
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        Image(.welcomeDuck)
                            .offset(y: -70)
                        VStack{
                            Spacer()
                            VStack{
                                Text("Welcome to")
                                Text("DuckBlock")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Button (action: {
                                    navManager.navTo("permission-screentime")
                                }){
                                    Text("Let's go")
                                }
                                .pillButton()
                            }
                            .padding(.bottom, 100)
                        }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
            .navigationBarBackButtonHidden(true)
    }
}

struct SplashView_Preview: PreviewProvider {
    struct Container: View {
        @State private var tutorialConfig = TutorialConfig(isTutorial: true)
        @State private var navManager = NavManager()
        
        var body: some View {
            NavStackView {
                SplashView()
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
