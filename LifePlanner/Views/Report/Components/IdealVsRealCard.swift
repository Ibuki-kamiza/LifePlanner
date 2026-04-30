//
//  IdealVsRealCard.swift
//  LifePlanner
//
import SwiftUI

struct IdealVsRealCard: View {
    let goals: [Goal]
    let todos: [TodoItem]

    var averageGoalProgress: Double {
        guard !goals.isEmpty else { return 0 }
        return goals.reduce(0) { $0 + $1.progress } / Double(goals.count)
    }

    var todoCompletionRate: Double {
        let total = todos.filter { !$0.isSchedule }.count
        guard total > 0 else { return 0 }
        let completed = todos.filter { !$0.isSchedule && $0.isCompleted }.count
        return Double(completed) / Double(total)
    }

    var gap: Double {
        1.0 - averageGoalProgress
    }

    var gapLabel: String {
        if gap <= 0.1 { return "理想に近い状態です🎉" }
        if gap <= 0.3 { return "少しギャップがあります💪" }
        if gap <= 0.6 { return "課題があります。行動を増やしましょう🌱" }
        return "大きなギャップがあります。小さな一歩から始めましょう✨"
    }

    var gapColor: Color {
        if gap <= 0.1 { return .green }
        if gap <= 0.3 { return .blue }
        if gap <= 0.6 { return .orange }
        return .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundColor(.indigo)
                Text("理想と現実")
                    .font(AppStyle.headlineFont)
            }

            if goals.isEmpty {
                Text("目標を追加すると分析できます")
                    .font(AppStyle.captionFont)
                    .foregroundColor(AppStyle.secondaryText)
            } else {
                VStack(spacing: 12) {
                    // 理想
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("理想（目標達成率）")
                                .font(AppStyle.captionFont)
                                .foregroundColor(AppStyle.secondaryText)
                            Spacer()
                            Text("100%")
                                .font(AppStyle.captionFont)
                                .foregroundColor(.indigo)
                        }
                        ProgressView(value: 1.0)
                            .accentColor(.indigo.opacity(0.3))
                    }

                    // 現実
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("現実（平均進捗）")
                                .font(AppStyle.captionFont)
                                .foregroundColor(AppStyle.secondaryText)
                            Spacer()
                            Text("\(Int(averageGoalProgress * 100))%")
                                .font(AppStyle.captionFont)
                                .foregroundColor(.blue)
                        }
                        ProgressView(value: averageGoalProgress)
                            .accentColor(.blue)
                    }

                    // Todo達成率
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("日々の行動（Todo達成率）")
                                .font(AppStyle.captionFont)
                                .foregroundColor(AppStyle.secondaryText)
                            Spacer()
                            Text("\(Int(todoCompletionRate * 100))%")
                                .font(AppStyle.captionFont)
                                .foregroundColor(.green)
                        }
                        ProgressView(value: todoCompletionRate)
                            .accentColor(.green)
                    }

                    // ギャップメッセージ
                    Text(gapLabel)
                        .font(AppStyle.captionFont)
                        .foregroundColor(gapColor)
                        .padding(8)
                        .background(gapColor.opacity(0.1))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
    let goal1 = Goal(title: "フルスタックエンジニアになる", detail: "", targetYear: 3, category: "キャリア")
    goal1.progress = 0.3
    let goal2 = Goal(title: "年収600万円達成", detail: "", targetYear: 5, category: "お金")
    goal2.progress = 0.1
    return IdealVsRealCard(goals: [goal1, goal2], todos: [])
}
