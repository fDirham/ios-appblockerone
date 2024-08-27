//
//  NewAppGroupView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/14/24.
//

import SwiftUI
import CoreData

struct NewAppGroupView: View {
    @Environment(TutorialConfig.self) private var tutorialConfig
    @Environment(\.managedObjectContext) private var viewContext
    @State private var sm: AppGroupSettingsModel

    init(coreDataContext: NSManagedObjectContext){
        sm = AppGroupSettingsModel(coreDataContext: coreDataContext)
    }
    
    var body: some View {
        AppGroupSettingsView(onSave: {
            return sm.handleSaveNew()
        }, navTitle: "New")
        .environment(sm)
    }
}

struct NewAppGroupView_Preview: PreviewProvider {
    struct Container: View {
        let coreDataContext = PersistenceController.preview.container.viewContext
        @State private var tutorialConfig = TutorialConfig()
        
        var body: some View {
            NavigationStack{
                NewAppGroupView(coreDataContext: coreDataContext)
                    .environment(\.managedObjectContext, coreDataContext)
                    .environment(tutorialConfig)
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
