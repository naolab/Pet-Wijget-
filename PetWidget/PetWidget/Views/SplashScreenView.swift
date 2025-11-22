//
//  SplashScreenView.swift
//  PetWidget
//
//  Created by Claude on 2025/11/22.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var opacity: Double = 0.0
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            HStack(spacing: 16) {
                // アプリアイコン
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)

                // アプリ名
                Text("PETWIJGET")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
            }
            .opacity(opacity)
        }
        .onAppear {
            // フェードインアニメーション
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1.0
            }

            // 1.2秒表示した後、フェードアウト
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.6)) {
                    opacity = 0.0
                }

                // フェードアウト完了後に非表示
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(isPresented: .constant(true))
}
