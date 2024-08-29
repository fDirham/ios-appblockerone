//
//  StoreView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/29/24.
//

import SwiftUI
import StoreKit

struct CustomStoreView: View {
    var body: some View {
        Color.bg
            .ignoresSafeArea()
            .overlay {
                ScrollView{
                    VStack{
                        Image("blockScreenPreview")
                            .padding(.top, 16)
                        ProductView(id: "duckblock.duckshield")
                            .padding(.top, 6)
                    }
                    .padding()
                }
            }
    }
}

#Preview {
    CustomStoreView()
}
