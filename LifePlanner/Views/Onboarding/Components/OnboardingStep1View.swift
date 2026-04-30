//
//  OnboardingStep1View.swift
//  LifePlanner
//
import SwiftUI

struct OnboardingStep1View: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // アイコン
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.4, green: 0.25, blue: 0.1), .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Text("LP")
                    .font(.custom("Zapfino", size: 36))
                    .foregroundColor(.white)
            }

            // タイトル
            VStack(spacing: 12) {
                Text("LifePlanner")
                    .font(.custom("Zapfino", size: 32))
                    .foregroundColor(Color(red: 0.4, green: 0.25, blue: 0.1))

                Text("人生を計画し、夢を実現する")
                    .font(.headline)
                    .foregroundColor(.gray)
            }

            // 機能紹介
            VStack(spacing: 16) {
                featureRow(icon: "target", color: .orange, title: "人生目標の設定", description: "10年・20年先の目標をタイムラインで管理")
                featureRow(icon: "checkmark.circle.fill", color: .blue, title: "Todo・スケジュール管理", description: "日々のタスクとスケジュールを一元管理")
                featureRow(icon: "sparkles", color: .yellow, title: "AIアシスタント", description: "Gemini AIがあなたの目標達成をサポート")
                featureRow(icon: "chart.bar.fill", color: .purple, title: "行動レポート", description: "習慣分析で理想と現実のギャップを可視化")
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    private func featureRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

#Preview {
    OnboardingStep1View()
}
