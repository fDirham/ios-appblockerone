//
//  ContentView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(NavManager.self) private var navManager
    
    var body: some View {
        NavStackView {
            HomeView()
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
                        HomeView()
                    case "new-group":
                        NewAppGroupView(coreDataContext: viewContext)
                    case "help":
                        HelpView()
                    case "tutorial-0":
                        Tutorial0View()
                    case "tutorial-1":
                        Tutorial1View()
                    case "tutorial-2":
                        Tutorial2View()
                    case "splash":
                        SplashView()
                    case "permission-screentime":
                        PermissionsScreentimeView()
                    case "permission-notification":
                        PermissionsNotificationsView()
                    default:
                        if np.pathId.starts(with: "edit-group-") {
                            EditAppGroupView(coreDataContext: viewContext, appGroup: np.appGroup!)
                        }
                        else {
                            EmptyView()
                        }
                    }
                }
        }
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
