//
//  NewAppGroupView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/14/24.
//

import SwiftUI
import CoreData

struct NewAppGroupView: View {
    @State private var sm: AppGroupSettingsModel
    @Environment(\.managedObjectContext) private var viewContext

    init(coreDataContext: NSManagedObjectContext){
        sm = AppGroupSettingsModel(coreDataContext: coreDataContext)
    }
    
    var body: some View {
        AppGroupSettingsView(onSave: {
            return sm.handleSaveNew()
        }, navTitle: "New")
        .environment(sm)
        .onDisappear {
            var _ = try? sm._syncCDObjWithSelf()
        }
    }
}

struct NewAppGroupView_Preview: PreviewProvider {
    struct Container: View {
        let coreDataContext = PersistenceController.preview.container.viewContext
        var body: some View {
            NavigationStack{
                NewAppGroupView(coreDataContext: coreDataContext)
                    .environment(\.managedObjectContext, coreDataContext)
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
