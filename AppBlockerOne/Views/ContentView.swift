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
                    VStack(alignment: .leading){
                        Text("Blocked groups")
                            .multilineTextAlignment(.leading)
                            .font(.custom("Poppins-Bold", size: 28, relativeTo: .title))
                            .padding(.top)
                            .padding(.horizontal)
                            .padding(.bottom, 4)
                        ScrollView {
                            LazyVGrid(columns: columns, alignment: .leading) {
                                ForEach(appGroups) {appGroup in
                                    AppGroupBlockView(appGroup: appGroup)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            NavigationLink(destination: Text("TODO")) {
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
                    .toolbarBackground(.bg)
                }
        }
    }
    
    //    private func deleteItems(offsets: IndexSet) {
    //        withAnimation {
    //            offsets.map { items[$0] }.forEach(viewContext.delete)
    //
    //            do {
    //                try viewContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nsError = error as NSError
    //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //            }
    //        }
    //    }
}

struct AppGroupBlockView: View {
    let appGroup: AppGroup
    
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)
    
    private var faSelection: FamilyActivitySelection {
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
            .roundedBG(fill: getColor(colorString: appGroup.groupColor!))
            Text(appGroup.groupName!)
        }
    }
        
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
