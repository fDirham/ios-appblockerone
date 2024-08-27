//
//  PermissionsScreentimeView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import SwiftUI
import FamilyControls

struct PermissionsScreentimeView: View {
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
                            await askScreentimePermissions()
                        }
                    }) {
                        Text("Grant permissions")
                    }
                    .pillButton()
                }
            }
            .task {
                await askScreentimePermissions()
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
        let center = UNUserNotificationCenter.current()
        do
        {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            onGranted()
        }
        catch {
            alertMsg = "Failed to authorize ScreenTime"
            debugPrint("ScreenTime permissions failed \(error.localizedDescription)")
        }
    }
    
    private func onGranted(){
        debugPrint("TODO")
    }
}

#Preview {
    PermissionsScreentimeView()
}
