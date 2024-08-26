//
//  ContentView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI
import CoreData
import FamilyControls
import OSLog
import ManagedSettings

let logger = Logger()

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppGroup.timestamp, ascending: true)],
        animation: .default)
    private var appGroups: FetchedResults<AppGroup>
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            Color.bg
                .ignoresSafeArea()
                .overlay {
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(appGroups) {appGroup in
                                NavigationLink(destination: EditAppGroupView(coreDataContext: viewContext, appGroup: appGroup)) {
                                    
                                    AppGroupBlockView(appGroup: appGroup)
                                    
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    .navigationTitle("Blocked groups")
                    .padding(.horizontal)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            NavigationLink(destination: HelpView()) {
                                Text("Help")
                                    .foregroundStyle(.accent)
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(destination: NewAppGroupView(coreDataContext: viewContext)) {
                                Image(systemName: "plus")
                                    .foregroundStyle(.accent)
                            }
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
            logger.error("Can't decode family activity selection for \(appGroup.groupName ?? "Unknown???")")
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

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
