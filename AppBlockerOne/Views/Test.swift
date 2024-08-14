//
//  Test.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI

struct Test: View {
    @State var selectedNumber: Int = 0
    
    var body: some View {
        Menu {
            Picker(selection: $selectedNumber, label: EmptyView()) {
                ForEach(0..<10) {
                    Text("\($0)")
                }
            }
        } label: {
            customLabel
        }
    }
    
    var customLabel: some View {
        HStack {
            Image(systemName: "paperplane")
            Text(String(selectedNumber))
            Spacer()
            Text("⌵")
                .offset(y: -4)
        }
        .foregroundColor(.white)
        .font(.title)
        .padding()
        .frame(height: 32)
        .background(Color.blue)
        .cornerRadius(16)
    }
}

#Preview {
    Test()
}
