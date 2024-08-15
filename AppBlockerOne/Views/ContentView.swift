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
        Color.bg
            .ignoresSafeArea()
            .overlay {
                NavigationStack {
                    VStack{
                        ForEach(appGroups) {appGroup in
                            HStack {
                                Text(appGroup.groupName!)
                            }
                            .padding()
                            .background(getColor(colorString: appGroup.groupColor!))
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(destination: NewAppGroupView()) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
    }
    //
    //    private func addItem() {
    //        withAnimation {
    //            let newItem = Item(context: viewContext)
    //            newItem.timestamp = Date()
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
