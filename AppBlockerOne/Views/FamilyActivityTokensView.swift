//
//  FamilyActivityTokensView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/15/24.
//

import SwiftUI
import ManagedSettings
import FamilyControls

struct FamilyActivityTokensView: View{
    var faSelection: FamilyActivitySelection
    var maxIconsToShow = 12
    
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
        if aptList.count > maxIconsToShow {
            return maxIconsToShow
        }
        return aptList.count
    }
    
    var actListToShowNum: Int {
        let remainder = maxIconsToShow - aptListToShowNum
        if remainder <= 0 {
            return 0
        }
        if actList.count >= remainder {
            return remainder
        }
        return actList.count
    }
    
    var wdtListToShowNum: Int {
        let remainder = maxIconsToShow - aptListToShowNum - actListToShowNum
        if remainder <= 0 {
            return 0
        }
        if wdtList.count >= remainder {
            return remainder
        }
        return wdtList.count
    }
    
    static func isNoTokens(faSelection: FamilyActivitySelection) -> Bool{
        let aptList = faSelection.applicationTokens
        let actList = faSelection.categoryTokens
        let wdtList = faSelection.webDomainTokens
        
        return aptList.isEmpty && actList.isEmpty && wdtList.isEmpty
    }
    
    var body: some View {
        if isPreview {
            ForEach(0..<maxIconsToShow, id: \.hashValue) { _ in
                Rectangle()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.cyan)
                    .backgroundStyle(.cyan)
            }
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
            
        }
    }
}

#Preview {
    FamilyActivityTokensView(faSelection: FamilyActivitySelection())
}
