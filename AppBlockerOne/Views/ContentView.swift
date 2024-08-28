//
//  ContentView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(TutorialConfig.self) private var tutorialConfig
    @Environment(NavManager.self) private var navManager
    
    var body: some View {
        NavStackView {
            HelloWorld()
        }
        .onAppear {
            // Check tutorial
            let ud = GroupUserDefaults()
            let isTutorialDone = ud.bool(forKey: DEFAULT_KEY_TUTORIAL_DONE)
            if isTutorialDone {
                tutorialConfig.isTutorial = false
                navManager.navTo("home")
            }
            else {
                tutorialConfig.isTutorial = true
                navManager.navTo("splash")
            }
        }
    }
}

struct NavStackView<Content: View>: View{
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(NavManager.self) private var navManager
    
    @ViewBuilder let root: Content

    var body: some View {
        @Bindable var nm = navManager
        
        NavigationStack(path: $nm.pathStack){
            root
                .navigationDestination(for: NavPath.self) { np in
                    switch np.pathId {
                    case "home":
                        NavigationLazyView(HomeView())
                    case "new-group":
                        NavigationLazyView(NewAppGroupView(coreDataContext: viewContext))
                    case "help":
                        NavigationLazyView(HelpView())
                    case "tutorial-0":
                        NavigationLazyView(Tutorial0View())
                    case "tutorial-1":
                        NavigationLazyView(Tutorial1View())
                    case "tutorial-2":
                        NavigationLazyView(Tutorial2View())
                    case "splash":
                        NavigationLazyView(SplashView())
                    case "permission-screentime":
                        NavigationLazyView(PermissionsScreentimeView())
                    case "permission-notification":
                        NavigationLazyView(PermissionsNotificationsView())
                    default:
                        if np.pathId.starts(with: "edit-group-") {
                            NavigationLazyView(EditAppGroupView(coreDataContext: viewContext, appGroup: np.appGroup!))
                        }
                        else {
                            EmptyView()
                        }
                    }
                }
        }
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}


struct ContentView_Preview: PreviewProvider {
    struct Container: View {
        @State private var tutorialConfig = TutorialConfig()
        @State private var navManager = NavManager()

        var body: some View {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environment(tutorialConfig)
                .environment(navManager)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
