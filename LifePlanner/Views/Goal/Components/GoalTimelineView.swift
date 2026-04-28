//
//  GoalTimelineView.swift
//  LifePlanner
//
import SwiftUI

struct GoalTimelineView: View {
    let goals: [Goal]
    let currentYear: Int
    let onTap: (Goal) -> Void

    var sortedGoals: [Goal] {
        goals.sorted { $0.targetYear < $1.targetYear }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sortedGoals.enumerated()), id: \.element.id) { index, goal in
                HStack(alignment: .top, spacing: 12) {
                    // タイムライン左側
                    VStack(spacing: 0) {
                        Circle()
                            .fill(goal.isCompleted ? Color.green : Color.blue)
                            .frame(width: 12, height: 12)
                            .padding(.top, 4)

                        if index < sortedGoals.count - 1 {
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 12)

                    // 目標カード
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(currentYear + goal.targetYear)年（\(goal.targetYear)年後）")
                            .font(.caption2)
                            .foregroundColor(AppStyle.secondaryText)

                        Text(goal.title)
                            .font(AppStyle.bodyFont)
                            .fontWeight(.semibold)
                            .foregroundColor(goal.isCompleted ? AppStyle.secondaryText : AppStyle.primaryText)
                            .strikethrough(goal.isCompleted)

                        ProgressView(value: goal.progress)
                            .accentColor(goal.isCompleted ? .green : .blue)

                        Text("進捗 \(Int(goal.progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(AppStyle.secondaryText)
                    }
                    .padding(10)
                    .background(AppStyle.cardBackground)
                    .cornerRadius(AppStyle.cornerRadius)
                    .contentShape(Rectangle())
                    .onTapGesture { onTap(goal) }

                    Spacer()
                }
                .padding(.bottom, index < sortedGoals.count - 1 ? 0 : 8)
                .frame(minHeight: 80)
            }
        }
        .padding(.horizontal, AppStyle.horizontalPadding)
    }
}

#Preview {
    let goal1 = Goal(title: "フルスタックエンジニアになる", detail: "", targetYear: 3, category: "キャリア")
    goal1.progress = 0.3
    let goal2 = Goal(title: "年収600万円達成", detail: "", targetYear: 5, category: "お金")
    goal2.progress = 0.1
    let goal3 = Goal(title: "ITコンサルタントになる", detail: "", targetYear: 10, category: "キャリア")
    return GoalTimelineView(
        goals: [goal1, goal2, goal3],
        currentYear: 2026,
        onTap: { _ in }
    )
}
