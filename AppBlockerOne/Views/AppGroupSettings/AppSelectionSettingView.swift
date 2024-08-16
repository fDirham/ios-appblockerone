//
//  AppSelectionSettingView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/14/24.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct AppSelectionSettingView: View {
    @Binding var faSelection: FamilyActivitySelection
    @State private var showFaPicker = false
    
    private let MAX_ICONS_TO_SHOW = 12
    
    var isNoTokens: Bool {
        FamilyActivityTokensView.isNoTokens(faSelection: faSelection)
    }
    
    var body: some View {
        Button(action: {
            showFaPicker = true
        }) {
            ScrollView(.horizontal) {
                HStack {
                    if isNoTokens {
                        Text("Tap here...")
                            .foregroundStyle(.fgFaint)
                    }
                    else {
                        FamilyActivityTokensView(faSelection: faSelection, maxIconsToShow: MAX_ICONS_TO_SHOW)
                        Spacer()
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .settingBlockBG()
        .familyActivityPicker(isPresented: $showFaPicker, selection: $faSelection)
    }
}

struct AppSelectionSettingView_Preview: PreviewProvider {
    struct Container: View {
        @State private var faSelection = FamilyActivitySelection()
        
        var body: some View {
            AppSelectionSettingView(faSelection: $faSelection)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
