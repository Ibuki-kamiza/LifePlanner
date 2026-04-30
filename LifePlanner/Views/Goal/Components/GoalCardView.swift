//
//  GoalCardView.swift
//  LifePlanner
//
import SwiftUI

struct GoalCardView: View {
    let goal: Goal
    let currentYear: Int

    var targetLabel: String {
        if goal.usesSpecificDate, let date = goal.targetDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年M月d日"
            let yearsLeft = Calendar.current.dateComponents([.year], from: Date(), to: date).year ?? 0
            return "\(formatter.string(from: date))（\(yearsLeft)年後）"
        }
        return "\(currentYear + goal.targetYear)年（\(goal.targetYear)年後）"
    }

    var categoryColor: Color {
        switch goal.category {
        case "キャリア": return .blue
        case "健康": return .green
        case "学習": return .orange
        case "お金": return .yellow
        case "人間関係": return .pink
        default: return .purple
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(goal.category.isEmpty ? "その他" : goal.category)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(categoryColor)
                    .cornerRadius(8)

                Spacer()

                Text(targetLabel)
                    .font(AppStyle.captionFont)
                    .foregroundColor(AppStyle.secondaryText)
            }

            Text(goal.title)
                .font(AppStyle.bodyFont)
                .fontWeight(.semibold)
                .foregroundColor(AppStyle.primaryText)

            if !goal.detail.isEmpty {
                Text(goal.detail)
                    .font(AppStyle.captionFont)
                    .foregroundColor(AppStyle.secondaryText)
                    .lineLimit(2)
            }

            ProgressView(value: goal.progress)
                .accentColor(categoryColor)

            HStack {
                Text("進捗 \(Int(goal.progress * 100))%")
                    .font(AppStyle.captionFont)
                    .foregroundColor(AppStyle.secondaryText)
                Spacer()
                if goal.isCompleted {
                    Text("✅ 達成")
                        .font(AppStyle.captionFont)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(AppStyle.cardPadding)
        .background(AppStyle.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .padding(.horizontal, AppStyle.horizontalPadding)
    }
}

#Preview {
    let goal = Goal(title: "フルスタックエンジニアになる", detail: "JavaとSwiftを使いこなす", targetYear: 3, category: "キャリア")
    goal.progress = 0.3
    return GoalCardView(goal: goal, currentYear: 2026)
}
