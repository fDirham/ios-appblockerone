//
//  PermissionsScreentimeView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import SwiftUI
import FamilyControls

struct PermissionsNotificationsView: View {
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
                        askNotificationPermissions()
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
            }
            .task {
                askNotificationPermissions()
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
        debugPrint("TODO")
    }
    
    private func onSkip(){
        debugPrint("TODO")
    }
}

#Preview {
    PermissionsNotificationsView()
}
