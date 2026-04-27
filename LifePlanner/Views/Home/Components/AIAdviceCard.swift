//
//  AIAdviceCard.swift
//  LifePlanner
//
import SwiftUI

struct AIAdviceCard: View {
    let aiName: String
    let message: String
    let isLoading: Bool
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text(aiName)
                    .font(AppStyle.headlineFont)
            }
            if isLoading {
                HStack {
                    ProgressView()
                    Text("考え中...")
                        .foregroundColor(AppStyle.secondaryText)
                }
            } else {
                Text(message.isEmpty ? "「更新」を押してアドバイスを取得しましょう" : message)
                    .font(AppStyle.bodyFont)
                    .foregroundColor(AppStyle.secondaryText)
            }
            Button(action: onRefresh) {
                Label("更新", systemImage: "arrow.clockwise")
                    .font(AppStyle.captionFont)
            }
        }
        .padding(AppStyle.cardPadding)
        .background(AppStyle.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .padding(.horizontal, AppStyle.horizontalPadding)
    }
}

#Preview {
    AIAdviceCard(
        aiName: "ライフコーチ",
        message: "今日も一歩ずつ進みましょう",
        isLoading: false,
        onRefresh: {}
    )
}
