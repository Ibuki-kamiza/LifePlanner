//
//  GoalProgressCard.swift
//  LifePlanner
//
import SwiftUI

struct GoalProgressCard: View {
    let goal: Goal
    let currentYear: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.orange)
                Text("直近の目標")
                    .font(AppStyle.headlineFont)
            }
            Text(goal.title)
                .font(AppStyle.bodyFont)
                .fontWeight(.semibold)
            Text("\(currentYear + goal.targetYear)年達成目標（\(goal.targetYear)年後）")
                .font(AppStyle.captionFont)
                .foregroundColor(AppStyle.secondaryText)
            ProgressView(value: goal.progress)
                .accentColor(.orange)
            Text("進捗 \(Int(goal.progress * 100))%")
                .font(AppStyle.captionFont)
                .foregroundColor(AppStyle.secondaryText)
        }
        .padding(AppStyle.cardPadding)
        .background(AppStyle.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .padding(.horizontal, AppStyle.horizontalPadding)
    }
}

#Preview {
    GoalProgressCard(
        goal: Goal(title: "フルスタックエンジニアになる", detail: "", targetYear: 3, category: "キャリア"),
        currentYear: 2026
    )
}
