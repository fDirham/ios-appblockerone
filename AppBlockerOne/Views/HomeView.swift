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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppGroup.timestamp, ascending: true)],
        animation: .default)
    private var appGroups: FetchedResults<AppGroup>
    
    @State private var navPaths: [String] = []
    
    var showHelpButton: Bool {
        return !tutorialConfig.isTutorial
    }

    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack(path: $navPaths) {
            Color.bg
                .ignoresSafeArea()
                .overlay {
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(appGroups) {appGroup in
                                NavigationLink( destination: {
                                    EditAppGroupView(coreDataContext: viewContext, appGroup: appGroup)
                                }) {
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
                                NavigationLink(destination: HelpView()) {
                                    Text("Help")
                                        .foregroundStyle(.accent)
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                tutorialConfig.triggerEndStage(forStage: 0)
                                navPaths.append("new")
                            }){
                                Image(systemName: "plus")
                                    .foregroundStyle(.accent)
                            }
                        }
                    }
                }
                .navigationDestination(for: String.self, destination: {val in
                    if val == "new" {
                        NewAppGroupView(coreDataContext: viewContext)
                    }
                    else{
                        EmptyView()
                    }
                })
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
        
        var body: some View {
            HomeView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environment(tutorialConfig)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
