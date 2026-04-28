//
//  GoalDetailView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var personalities: [AIPersonality]

    @Bindable var goal: Goal

    @State private var isEditing: Bool = false
    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var targetYear: Int = 5
    @State private var category: String = "キャリア"
    @State private var aiSimulation: String = ""
    @State private var isLoadingAI: Bool = false

    let categories = ["キャリア", "健康", "学習", "お金", "人間関係", "その他"]
    let years = Array(1...50)

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppStyle.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        if isEditing {
                            editingSection
                        } else {
                            detailSection
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("目標詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    if isEditing {
                        Button("完了") { saveChanges() }
                            .fontWeight(.bold)
                    } else {
                        Button("編集") { startEditing() }
                    }
                }
            }
        }
    }

    // 詳細表示
    private var detailSection: some View {
        VStack(spacing: 16) {
            // 目標カード
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(goal.category.isEmpty ? "その他" : goal.category)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.blue)
                        .cornerRadius(8)
                    Spacer()
                    Text("\(currentYear + goal.targetYear)年（\(goal.targetYear)年後）")
                        .font(AppStyle.captionFont)
                        .foregroundColor(AppStyle.secondaryText)
                }
                Text(goal.title)
                    .font(.title3)
                    .fontWeight(.bold)
                if !goal.detail.isEmpty {
                    Text(goal.detail)
                        .font(AppStyle.bodyFont)
                        .foregroundColor(AppStyle.secondaryText)
                }
                ProgressView(value: goal.progress)
                    .accentColor(.blue)
                HStack {
                    Text("進捗 \(Int(goal.progress * 100))%")
                        .font(AppStyle.captionFont)
                        .foregroundColor(AppStyle.secondaryText)
                    Spacer()
                    Button(goal.isCompleted ? "未完了に戻す" : "達成済みにする") {
                        goal.isCompleted.toggle()
                    }
                    .font(AppStyle.captionFont)
                    .foregroundColor(goal.isCompleted ? .gray : .green)
                }

                // 進捗スライダー
                VStack(alignment: .leading, spacing: 4) {
                    Text("進捗を更新")
                        .font(AppStyle.captionFont)
                        .foregroundColor(AppStyle.secondaryText)
                    Slider(value: $goal.progress, in: 0...1, step: 0.05)
                        .accentColor(.blue)
                }
            }
            .padding(AppStyle.cardPadding)
            .background(AppStyle.cardBackground)
            .cornerRadius(AppStyle.cornerRadius)
            .padding(.horizontal, AppStyle.horizontalPadding)

            // 未来シミュレーション
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                    Text("未来シミュレーション")
                        .font(AppStyle.headlineFont)
                    Spacer()
                    Button(action: fetchSimulation) {
                        Label("生成", systemImage: "arrow.clockwise")
                            .font(AppStyle.captionFont)
                    }
                }
                if isLoadingAI {
                    HStack {
                        ProgressView()
                        Text("AIが分析中...")
                            .foregroundColor(AppStyle.secondaryText)
                    }
                } else {
                    Text(aiSimulation.isEmpty ? "「生成」を押すとAIが進捗予測とアドバイスを表示します" : aiSimulation)
                        .font(AppStyle.bodyFont)
                        .foregroundColor(aiSimulation.isEmpty ? AppStyle.secondaryText : AppStyle.primaryText)
                }
            }
            .padding(AppStyle.cardPadding)
            .background(AppStyle.cardBackground)
            .cornerRadius(AppStyle.cornerRadius)
            .padding(.horizontal, AppStyle.horizontalPadding)

            // 削除ボタン
            Button(role: .destructive) {
                modelContext.delete(goal)
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("削除する")
                    Spacer()
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(AppStyle.cornerRadius)
            }
            .padding(.horizontal, AppStyle.horizontalPadding)
        }
    }

    // 編集フォーム
    private var editingSection: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("目標")) {
                    TextField("タイトル", text: $title)
                    TextField("詳細（任意）", text: $detail, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section(header: Text("達成目標年")) {
                    Picker("何年後", selection: $targetYear) {
                        ForEach(years, id: \.self) { year in
                            Text("\(year)年後").tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }

                Section(header: Text("カテゴリ")) {
                    Picker("カテゴリ", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .frame(height: 500)
            .scrollDisabled(true)
        }
    }

    private func startEditing() {
        title = goal.title
        detail = goal.detail
        targetYear = goal.targetYear
        category = goal.category
        isEditing = true
    }

    private func saveChanges() {
        goal.title = title
        goal.detail = detail
        goal.targetYear = targetYear
        goal.category = category
        isEditing = false
    }

    private func fetchSimulation() {
        guard let personality = personalities.first else { return }
        isLoadingAI = true

        let prompt = """
        目標：\(goal.title)
        詳細：\(goal.detail)
        達成目標：\(goal.targetYear)年後（\(currentYear + goal.targetYear)年）
        現在の進捗：\(Int(goal.progress * 100))%
        カテゴリ：\(goal.category)

        このユーザーの目標に対して以下を教えてください：
        1. このままのペースだと何年後に達成できそうか
        2. 1年後にどこまで到達できそうか
        3. 達成のための具体的なアクション3つ
        200文字以内で簡潔に答えてください。
        """

        Task {
            do {
                let result = try await GeminiService.shared.generate(prompt: prompt, personality: personality)
                await MainActor.run {
                    aiSimulation = result
                    isLoadingAI = false
                }
            } catch {
                await MainActor.run {
                    aiSimulation = "シミュレーションを取得できませんでした"
                    isLoadingAI = false
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Goal.self, AIPersonality.self,
        configurations: config
    )
    let goal = Goal(title: "フルスタックエンジニアになる", detail: "JavaとSwiftを使いこなす", targetYear: 3, category: "キャリア")
    goal.progress = 0.3
    container.mainContext.insert(goal)
    return GoalDetailView(goal: goal)
        .modelContainer(container)
}
