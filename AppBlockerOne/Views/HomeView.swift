//
//  HomeView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import SwiftUI
import CoreData
import FamilyControls
import OSLog
import ManagedSettings

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(TutorialConfig.self) private var tutorialConfig
    @Environment(NavManager.self) private var navManager

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppGroup.timestamp, ascending: true)],
        animation: .default)
    private var appGroups: FetchedResults<AppGroup>
    
    var showHelpButton: Bool {
        return !tutorialConfig.isTutorial
    }
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        Color.bg
            .ignoresSafeArea()
            .overlay {
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .leading) {
                        ForEach(appGroups) {appGroup in
                            NavigationLink( value: NavPath(pathId: "edit-group-\(appGroup.id!.uuidString)", appGroup: appGroup)) {
                                AppGroupBlockView(appGroup: appGroup)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .navigationTitle("Blocked groups")
                .padding(.horizontal)
                .toolbar {
                    if showHelpButton {
                        ToolbarItem(placement: .topBarLeading) {
                            NavigationLink(value: NavPath(pathId: "help")) {
                                Text("Help")
                                    .foregroundStyle(.accent)
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            if tutorialConfig.isTutorial {
                                tutorialConfig.triggerEndStage(forStage: 0)
                                navManager.navTo(NavPath(pathId: "tutorial-1"))
                            }
                            else {
                                navManager.navTo(NavPath(pathId: "new-group"))
                            }
                        }){
                            Image(systemName: "plus")
                                .foregroundStyle(.accent)
                        }
                    }
                }
            }
    }
}

struct AppGroupBlockView: View {
    let appGroup: AppGroup
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)
    
    private var faSelection: FamilyActivitySelection {
        if appGroup.faSelection == nil {
            return FamilyActivitySelection()
        }
        
        do{
            return try decodeJSONObj(appGroup.faSelection ?? "")
        }
        catch {
            debugPrint("Can't decode family activity selection for \(appGroup.groupName ?? "Unknown???")")
            return FamilyActivitySelection()
        }
    }
    
    private let frameSize: CGFloat = 120
    private let cellSize: CGFloat = 40 // Make sure this is 1/3 of above
    
    private let MAX_ICONS_TO_SHOW = 9
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, alignment: .center, spacing: 0) {
                FamilyActivityTokensView(faSelection: faSelection, maxIconsToShow: MAX_ICONS_TO_SHOW)
                    .frame(width: cellSize, height: cellSize)
            }
            .frame(width: frameSize, height: frameSize, alignment: .top)
            .padding()
            .roundedBG(fill: .accentColor, cornerRadius: 12)
            .overlay( /// apply a rounded border
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.accentShade, lineWidth: 5)
            )
            .padding(.leading, 5)
            
            Text(appGroup.groupName ?? "")
                .foregroundStyle(Color.fg)
                .frame(maxWidth: frameSize)
        }
    }
    
}

struct HomeView_Preview: PreviewProvider {
    struct Container: View {
        @State private var tutorialConfig = TutorialConfig()
        @State private var navManager = NavManager()

        var body: some View {
            NavStackView {
                HomeView()
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
