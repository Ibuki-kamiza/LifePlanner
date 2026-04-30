//
//  AIReportCard.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct AIReportCard: View {
    let goals: [Goal]
    let todos: [TodoItem]
    let personality: AIPersonality?

    @State private var report: String = ""
    @State private var isLoading: Bool = false

    var completionRate: Double {
        let total = todos.filter { !$0.isSchedule }.count
        guard total > 0 else { return 0 }
        let completed = todos.filter { !$0.isSchedule && $0.isCompleted }.count
        return Double(completed) / Double(total)
    }

    var averageGoalProgress: Double {
        guard !goals.isEmpty else { return 0 }
        return goals.reduce(0) { $0 + $1.progress } / Double(goals.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundColor(.teal)
                Text("AIレポート")
                    .font(AppStyle.headlineFont)
                Spacer()
                Button(action: fetchReport) {
                    Label("生成", systemImage: "arrow.clockwise")
                        .font(AppStyle.captionFont)
                }
            }

            if isLoading {
                HStack {
                    ProgressView()
                    Text("AIがレポートを作成中...")
                        .foregroundColor(AppStyle.secondaryText)
                }
            } else {
                Text(report.isEmpty ? "「生成」を押すとAIが行動レポートを作成します" : report)
                    .font(AppStyle.bodyFont)
                    .foregroundColor(report.isEmpty ? AppStyle.secondaryText : AppStyle.primaryText)
            }
        }
        .padding(AppStyle.cardPadding)
        .background(AppStyle.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .padding(.horizontal, AppStyle.horizontalPadding)
    }

    private func fetchReport() {
        guard let personality = personality else { return }
        isLoading = true

        let goalList = goals.map { "・\($0.title)（進捗\(Int($0.progress * 100))%）" }.joined(separator: "\n")

        let hourlyActivity: [Int: Int] = {
            var activity: [Int: Int] = [:]
            for todo in todos where todo.isCompleted {
                let hour = Calendar.current.component(.hour, from: todo.createdAt)
                activity[hour, default: 0] += 1
            }
            return activity
        }()

        let peakHour = hourlyActivity.max(by: { $0.value < $1.value })?.key

        let prompt = """
        以下のユーザーデータをもとに行動レポートを作成してください。

        目標リスト：
        \(goalList.isEmpty ? "目標なし" : goalList)

        Todo達成率：\(Int(completionRate * 100))%
        目標平均進捗：\(Int(averageGoalProgress * 100))%
        最も集中できる時間帯：\(peakHour != nil ? "\(peakHour!):00〜\(peakHour! + 1):00" : "データなし")

        以下の内容を200文字以内で簡潔にまとめてください：
        1. 現状の評価
        2. 理想と現実のギャップ
        3. 改善のための具体的なアドバイス
        """

        Task {
            do {
                let result = try await GeminiService.shared.generate(prompt: prompt, personality: personality)
                await MainActor.run {
                    report = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    report = "レポートを取得できませんでした"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    AIReportCard(goals: [], todos: [], personality: nil)
}
