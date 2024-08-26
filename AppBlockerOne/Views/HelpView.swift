//
//  HelpView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/26/24.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        Color.bg
            .ignoresSafeArea()
            .overlay {
                Text("How do I block apps?")
                Text("TODO")
            }
            .navigationTitle("Help")
    }
}

struct HelpView_Preview: PreviewProvider {
    struct Container: View {
        var body: some View {
            NavigationStack{
                HelpView()
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
