//
//  NewAppGroupView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/14/24.
//

import SwiftUI

struct NewAppGroupView: View {
    @State private var sm: AppGroupSettingsModel = AppGroupSettingsModel()
    
    var body: some View {
        AppGroupSettingsView()
            .environment(sm)
    }
}

#Preview {
    NewAppGroupView()
}
