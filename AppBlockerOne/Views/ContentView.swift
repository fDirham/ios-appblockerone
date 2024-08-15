//
//  ContentView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppGroup.timestamp, ascending: true)],
        animation: .default)
    private var appGroups: FetchedResults<AppGroup>
    
    var body: some View {
        NavigationStack {
            Color.bg
                .ignoresSafeArea()
                .overlay {
                    ScrollView {
                        VStack{
                            ForEach(appGroups) {appGroup in
                                HStack {
                                    Text(appGroup.groupName!)
                                        .background(getColor(colorString: appGroup.groupColor!))
                                }
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(destination: NewAppGroupView(coreDataContext: viewContext)) {
                                Image(systemName: "plus")
                                    .foregroundColor(.accent)
                            }
                        }
                    }
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

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
