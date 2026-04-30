//
//  HabitAnalysisCard.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct HabitAnalysisCard: View {
    let todos: [TodoItem]

    var completionRate: Double {
        let total = todos.filter { !$0.isSchedule }.count
        guard total > 0 else { return 0 }
        let completed = todos.filter { !$0.isSchedule && $0.isCompleted }.count
        return Double(completed) / Double(total)
    }

    var streakDays: Int {
        let calendar = Calendar.current
        var streak = 0
        var date = Date()

        for _ in 0..<30 {
            let dayTodos = todos.filter {
                !$0.isSchedule &&
                calendar.isDate($0.createdAt, inSameDayAs: date)
            }
            let dayCompleted = dayTodos.filter { $0.isCompleted }
            if dayTodos.isEmpty || dayCompleted.isEmpty {
                break
            }
            streak += 1
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return streak
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("習慣分析")
                    .font(AppStyle.headlineFont)
            }

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(Int(completionRate * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Todo達成率")
                        .font(AppStyle.captionFont)
                        .foregroundColor(AppStyle.secondaryText)
                }

                Divider()

                VStack(spacing: 4) {
                    Text("\(streakDays)日")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("連続達成")
                        .font(AppStyle.captionFont)
                        .foregroundColor(AppStyle.secondaryText)
                }

                Divider()

                VStack(spacing: 4) {
                    Text("\(todos.filter { !$0.isSchedule && $0.isCompleted }.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("完了済み")
                        .font(AppStyle.captionFont)
                        .foregroundColor(AppStyle.secondaryText)
                }
            }
            .frame(maxWidth: .infinity)

            ProgressView(value: completionRate)
                .accentColor(.blue)

            // 精神的サポートメッセージ
            if completionRate >= 0.8 {
                supportMessage("素晴らしい！高い達成率を維持しています🎉", color: .green)
            } else if completionRate >= 0.5 {
                supportMessage("いい調子です。少しずつ前進しています💪", color: .blue)
            } else if completionRate > 0 {
                supportMessage("焦らず一歩ずつ。できることから始めましょう🌱", color: .orange)
            } else {
                supportMessage("今日から始めましょう。小さな一歩が大切です✨", color: .purple)
            }
        }
        .padding(AppStyle.cardPadding)
        .background(AppStyle.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .padding(.horizontal, AppStyle.horizontalPadding)
    }

    private func supportMessage(_ text: String, color: Color) -> some View {
        Text(text)
            .font(AppStyle.captionFont)
            .foregroundColor(color)
            .padding(8)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}

#Preview {
    HabitAnalysisCard(todos: [])
}
