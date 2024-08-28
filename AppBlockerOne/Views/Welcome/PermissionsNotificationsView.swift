//
//  PermissionsScreentimeView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import SwiftUI
import FamilyControls

struct PermissionsNotificationsView: View {
    @Environment(TutorialConfig.self) private var tutorialConfig
    @Environment(NavManager.self) private var navManager
    @State private var alertMsg: String? = nil

    private var isShowAlert: Binding<Bool> {
        Binding(get: {
            return alertMsg != nil
        }, set: {
            if !$0 {
                alertMsg = nil
            }
        })
    }
    
    var body: some View {
        Color.splashPond
            .ignoresSafeArea()
            .overlay {
                VStack{
                    Text("Allow notifications \n so we can notify you")
                        .multilineTextAlignment(.center)
                    Image(.notificationsLogo)
                    Spacer()
                    Button(action: {
                        if isPreview{
                            onGranted()
                        } else {
                            askNotificationPermissions()
                        }
                    }) {
                        Text("Grant permissions")
                    }
                    .pillButton()
                    Button(action: {
                        onSkip()
                    }){
                        Text("Skip")
                            .foregroundStyle(Color.danger)
                    }
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .task {
                do {
                    try await waitForS(seconds: 1)
                    askNotificationPermissions()
                }
                catch {
                    askNotificationPermissions()
                }
            }
            .alert(
                Text("Authorization Failed!"),
                isPresented: isShowAlert
            ) {
                Button("OK") {}
            } message: {
                Text(alertMsg ?? "")
            }
    }
    
    private func askNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                onGranted()
            } else {
                alertMsg = "Failed to authorize Notifications"
                debugPrint("Notifications permissions failed \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func onGranted(){
        if tutorialConfig.isTutorial {
            navManager.navTo("tutorial-0")
        }
        else {
            navManager.goBack()
        }
    }
    
    private func onSkip(){
        if tutorialConfig.isTutorial {
            navManager.navTo("tutorial-0")
        }
        else {
            navManager.goBack()
        }
    }
}

struct PermissionsNotificationsView_Preview: PreviewProvider {
    struct Container: View {
        @State private var tutorialConfig = TutorialConfig(isTutorial: true)
        @State private var navManager = NavManager()
        
        var body: some View {
            NavStackView {
                PermissionsNotificationsView()
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
