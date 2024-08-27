//
//  PermissionsScreentimeView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import SwiftUI
import FamilyControls

struct PermissionsScreentimeView: View {
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
                    Text("Allow ScreenTime access\n so we can block apps")
                        .multilineTextAlignment(.center)
                    Image(.screentimeLogo)
                    Spacer()
                    Button(action: {
                        Task {
                            if isPreview {
                                onGranted()
                            }
                            else {
                                await askScreentimePermissions()
                            }
                        }
                    }) {
                        Text("Grant permissions")
                    }
                    .pillButton()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .task {
                if !isPreview {
                    await askScreentimePermissions()
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
    
    private func askScreentimePermissions() async{
        do
        {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            onGranted()
        }
        catch {
            alertMsg = "Failed to authorize ScreenTime"
            debugPrint("ScreenTime permissions failed \(error.localizedDescription)")
        }
    }
    
    private func onGranted(){
        navManager.navTo("permission-notification")
    }
}

struct PermissionsScreentimeView_Preview: PreviewProvider {
    struct Container: View {
        @State private var tutorialConfig = TutorialConfig(isTutorial: true)
        @State private var navManager = NavManager()
        
        var body: some View {
            NavStackView {
                PermissionsScreentimeView()
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
