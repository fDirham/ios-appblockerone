//
//  EditAppGroupView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/15/24.
//

import SwiftUI
import CoreData

struct EditAppGroupView: View {
    @Environment(TutorialConfig.self) private var tutorialConfig
    @Environment(\.managedObjectContext) private var viewContext
    @State private var sm: AppGroupSettingsModel
    
    init(coreDataContext: NSManagedObjectContext, appGroup: AppGroup){
        sm = AppGroupSettingsModel(coreDataContext: coreDataContext, cdObj: appGroup)
    }
    
    var body: some View {
        AppGroupSettingsView(onSave: {
            return sm.handleSaveEdit()
        }, navTitle: "Edit")
        .environment(sm)
    }
}

struct EditAppGroupView_Preview: PreviewProvider {
    struct Container: View {
        let coreDataContext = PersistenceController.preview.container.viewContext
        let previewAppGroup = PersistenceController.previewObj
        @State private var tutorialConfig = TutorialConfig()

        var body: some View {
            NavigationStack{
                EditAppGroupView(coreDataContext: coreDataContext, appGroup: previewAppGroup)
                    .environment(\.managedObjectContext, coreDataContext)
                    .environment(tutorialConfig)
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
