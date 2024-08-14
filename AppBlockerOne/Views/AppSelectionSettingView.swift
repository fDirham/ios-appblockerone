//
//  AppSelectionSettingView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/14/24.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack{
            configuration.icon
        }
    }
}

struct AppSelectionSettingView: View {
    @Binding var faSelection: FamilyActivitySelection
    @State private var showFaPicker = false
    
    private let MAX_ICONS_TO_SHOW = 12
    
    init(faSelection: Binding<FamilyActivitySelection>){
        self._faSelection = faSelection
    }
    
    var aptList: [ApplicationToken] {
        Array(faSelection.applicationTokens)
    }
    
    var actList: [ActivityCategoryToken] {
        Array(faSelection.categoryTokens)
    }
    
    var wdtList: [WebDomainToken] {
        Array(faSelection.webDomainTokens)
    }
    
    var aptListToShowNum: Int {
        if aptList.count > MAX_ICONS_TO_SHOW {
            return MAX_ICONS_TO_SHOW
        }
        return aptList.count
    }
    
    var actListToShowNum: Int {
        let remainder = MAX_ICONS_TO_SHOW - aptListToShowNum
        if remainder <= 0 {
            return 0
        }
        if actList.count >= remainder {
            return remainder
        }
        return actList.count
    }
    
    var wdtListToShowNum: Int {
        let remainder = MAX_ICONS_TO_SHOW - aptListToShowNum - actListToShowNum
        if remainder <= 0 {
            return 0
        }
        if wdtList.count >= remainder {
            return remainder
        }
        return wdtList.count
    }
    
    var isNoTokens: Bool {
        wdtListToShowNum == 0 && actListToShowNum == 0 && aptListToShowNum == 0
    }
    
    var body: some View {
        Button(action: {
            showFaPicker = true
        }) {
            ScrollView(.horizontal) {
                HStack {
                    if isNoTokens {
                        Text("Tap here...")
                            .foregroundStyle(.fg)
                    }
                    else {
                        if aptListToShowNum > 0 {
                            ForEach(aptList[..<aptListToShowNum], id: \.hashValue) { token in
                                Label(token)
                                    .labelStyle(CustomLabelStyle())
                            }
                        }
                        if actListToShowNum > 0 {
                            ForEach(actList[..<actListToShowNum], id: \.hashValue) { token in
                                Label(token)
                                    .labelStyle(CustomLabelStyle())
                            }
                        }
                        if wdtListToShowNum > 0 {
                            ForEach(wdtList[..<wdtListToShowNum], id: \.hashValue) { token in
                                Label(token)
                                    .labelStyle(CustomLabelStyle())
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding()
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
