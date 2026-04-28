//
//  GoalView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct GoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @Query private var personalities: [AIPersonality]

    @State private var showAddGoal: Bool = false
    @State private var selectedGoal: Goal? = nil
    @State private var selectedTab: Int = 0
    @State private var aiRecommendation: String = ""
    @State private var isLoadingAI: Bool = false

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    var incompleteGoals: [Goal] {
        goals.filter { !$0.isCompleted }
    }

    var completedGoals: [Goal] {
        goals.filter { $0.isCompleted }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppStyle.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // タブ切替
                        Picker("表示", selection: $selectedTab) {
                            Text("タイムライン").tag(0)
                            Text("一覧").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        if selectedTab == 0 {
                            // タイムライン表示
                            if goals.isEmpty {
                                emptyView
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("人生タイムライン")
                                        .font(AppStyle.headlineFont)
                                        .padding(.horizontal, AppStyle.horizontalPadding)

                                    GoalTimelineView(
                                        goals: incompleteGoals,
                                        currentYear: currentYear,
                                        onTap: { goal in selectedGoal = goal }
                                    )

                                    if !completedGoals.isEmpty {
                                        Text("達成済み")
                                            .font(AppStyle.headlineFont)
                                            .foregroundColor(AppStyle.secondaryText)
                                            .padding(.horizontal, AppStyle.horizontalPadding)
                                            .padding(.top, 8)

                                        GoalTimelineView(
                                            goals: completedGoals,
                                            currentYear: currentYear,
                                            onTap: { goal in selectedGoal = goal }
                                        )
                                    }
                                }
                            }
                        } else {
                            // 一覧表示
                            if goals.isEmpty {
                                emptyView
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(incompleteGoals.sorted { $0.targetYear < $1.targetYear }) { goal in
                                        GoalCardView(goal: goal, currentYear: currentYear)
                                            .contentShape(Rectangle())
                                            .onTapGesture { selectedGoal = goal }
                                    }
                                    if !completedGoals.isEmpty {
                                        Text("達成済み")
                                            .font(AppStyle.headlineFont)
                                            .foregroundColor(AppStyle.secondaryText)
                                            .padding(.horizontal, AppStyle.horizontalPadding)
                                        ForEach(completedGoals.sorted { $0.targetYear < $1.targetYear }) { goal in
                                            GoalCardView(goal: goal, currentYear: currentYear)
                                                .contentShape(Rectangle())
                                                .onTapGesture { selectedGoal = goal }
                                        }
                                    }
                                }
                            }
                        }

                        // AIおすすめ
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                Text("AIからのおすすめ")
                                    .font(AppStyle.headlineFont)
                                Spacer()
                                Button(action: fetchRecommendation) {
                                    Label("生成", systemImage: "arrow.clockwise")
                                        .font(AppStyle.captionFont)
                                }
                            }
                            if isLoadingAI {
                                HStack {
                                    ProgressView()
                                    Text("AIが考え中...")
                                        .foregroundColor(AppStyle.secondaryText)
                                }
                            } else {
                                Text(aiRecommendation.isEmpty ? "「生成」を押すとAIが目標に対するおすすめスキルや行動を提案します" : aiRecommendation)
                                    .font(AppStyle.bodyFont)
                                    .foregroundColor(aiRecommendation.isEmpty ? AppStyle.secondaryText : AppStyle.primaryText)
                            }
                        }
                        .padding(AppStyle.cardPadding)
                        .background(AppStyle.cardBackground)
                        .cornerRadius(AppStyle.cornerRadius)
                        .padding(.horizontal, AppStyle.horizontalPadding)
                        .padding(.bottom, 80)
                    }
                    .padding(.vertical)
                }

                // 追加ボタン
                Button(action: { showAddGoal = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("目標")
                        .font(.headline)
                        .foregroundColor(AppStyle.accentBrown)
                }
            }
            .sheet(isPresented: $showAddGoal) {
                AddGoalView()
            }
            .sheet(item: $selectedGoal) { goal in
                GoalDetailView(goal: goal)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundColor(AppStyle.secondaryText)
            Text("目標がありません")
                .font(AppStyle.bodyFont)
                .foregroundColor(AppStyle.secondaryText)
            Text("右下の＋ボタンから目標を追加しましょう")
                .font(AppStyle.captionFont)
                .foregroundColor(AppStyle.secondaryText)
        }
        .padding(.top, 60)
    }

    private func fetchRecommendation() {
        guard let personality = personalities.first else { return }
        guard !goals.isEmpty else {
            aiRecommendation = "まず目標を追加してください"
            return
        }

        isLoadingAI = true

        let goalList = incompleteGoals.map { "・\($0.title)（\($0.targetYear)年後）" }.joined(separator: "\n")

        let prompt = """
        以下のユーザーの目標リストを見て、おすすめのスキル、ポートフォリオのアイデア、今すぐできる行動を3つ提案してください。
        200文字以内で簡潔に答えてください。

        目標リスト：
        \(goalList)
        """

        Task {
            do {
                let result = try await GeminiService.shared.generate(prompt: prompt, personality: personality)
                await MainActor.run {
                    aiRecommendation = result
                    isLoadingAI = false
                }
            } catch {
                await MainActor.run {
                    aiRecommendation = "おすすめを取得できませんでした"
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
    let goal1 = Goal(title: "フルスタックエンジニアになる", detail: "", targetYear: 3, category: "キャリア")
    goal1.progress = 0.3
    let goal2 = Goal(title: "年収600万円達成", detail: "", targetYear: 5, category: "お金")
    let goal3 = Goal(title: "ITコンサルタントになる", detail: "", targetYear: 10, category: "キャリア")
    container.mainContext.insert(goal1)
    container.mainContext.insert(goal2)
    container.mainContext.insert(goal3)
    let personality = AIPersonality(name: "ライフコーチ", characterType: "counselor", tone: "gentle", language: "ja")
    container.mainContext.insert(personality)
    return GoalView()
        .modelContainer(container)
}
