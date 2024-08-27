//
//  SplashView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        Color.splashBg
            .ignoresSafeArea()
            .overlay {
                GeometryReader { proxy in
                    ZStack() {
                        VStack(alignment: .center) {
                            Spacer()
                                .frame(height: proxy.size.height * 1)
                            Circle()
                                .fill(.splashPond)
                                .frame(width: 2 * proxy.size.width, height: 2 * proxy.size.width)
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        Image(.welcomeDuck)
                            .offset(y: -70)
                        VStack{
                            Spacer()
                            VStack{
                                Text("Welcome to")
                                Text("DuckBlock")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Button (action: {}){
                                    Text("Let's go")
                                }
                                .pillButton()
                            }
                            .padding(.bottom, 100)
                        }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
    }
}

#Preview {
    SplashView()
}
