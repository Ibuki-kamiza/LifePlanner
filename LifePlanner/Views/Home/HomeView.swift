//
//  HomeView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var personalities: [AIPersonality]
    @Query private var goals: [Goal]
    @Query private var todos: [TodoItem]

    @State private var aiMessage: String = ""
    @State private var isLoadingAI: Bool = false
    @State private var selectedTodo: TodoItem? = nil

    var todayTodos: [TodoItem] {
        let calendar = Calendar.current
        return todos.filter {
            !$0.isSchedule &&
            !$0.isCompleted &&
            ($0.dueDate == nil || calendar.isDateInToday($0.dueDate!))
        }
    }

    var todaySchedules: [TodoItem] {
        let calendar = Calendar.current
        return todos.filter {
            $0.isSchedule &&
            calendar.isDateInToday($0.scheduledAt ?? Date.distantPast)
        }
        .sorted { ($0.scheduledAt ?? Date.distantPast) < ($1.scheduledAt ?? Date.distantPast) }
    }

    var nearestGoal: Goal? {
        goals.filter { !$0.isCompleted }
            .sorted { $0.targetYear < $1.targetYear }
            .first
    }

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppStyle.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        AIAdviceCard(
                            aiName: personalities.first?.name ?? "AIアシスタント",
                            message: aiMessage,
                            isLoading: isLoadingAI,
                            onRefresh: fetchAIMessage
                        )

                        if let goal = nearestGoal {
                            GoalProgressCard(
                                goal: goal,
                                currentYear: currentYear
                            )
                        }

                        TodayTodoCard(
                            todos: todayTodos,
                            onToggle: toggleTodo,
                            onTap: { todo in selectedTodo = todo }
                        )

                        DayScheduleCard(
                            schedules: todaySchedules,
                            onTap: { schedule in selectedTodo = schedule }
                        )
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("LifePlanner")
                        .font(.custom("Zapfino", size: 20))
                        .foregroundColor(AppStyle.accentBrown)
                }
            }
            .sheet(item: $selectedTodo) { todo in
                TodoDetailView(item: todo)
            }
        }
    }

    private func toggleTodo(_ todo: TodoItem) {
        todo.isCompleted.toggle()
    }

    private func fetchAIMessage() {
        guard let personality = personalities.first else {
            aiMessage = "設定画面でAIアシスタントを設定してください"
            return
        }

        isLoadingAI = true

        let profileText = profiles.first.map {
            "ユーザー名：\($0.name)、職業・目標：\($0.occupation)"
        } ?? ""

        let goalText = nearestGoal.map {
            "直近の目標：\($0.title)（進捗\(Int($0.progress * 100))%）"
        } ?? "目標未設定"

        let prompt = """
        \(profileText)
        \(goalText)
        今日のTodo数：\(todayTodos.count)件

        上記のユーザーに今日の一言アドバイスを50文字以内で伝えてください。
        """

        Task {
            do {
                let message = try await GeminiService.shared.generate(prompt: prompt, personality: personality)
                await MainActor.run {
                    aiMessage = message
                    isLoadingAI = false
                }
            } catch {
                await MainActor.run {
                    aiMessage = "アドバイスを取得できませんでした"
                    isLoadingAI = false
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Goal.self, TodoItem.self, UserProfile.self, AIPersonality.self,
        configurations: config
    )

    let profile = UserProfile(name: "Ibuki", birthYear: 2000, occupation: "エンジニア志望")
    container.mainContext.insert(profile)

    let personality = AIPersonality(name: "ライフコーチ", characterType: "counselor", tone: "gentle", language: "ja")
    container.mainContext.insert(personality)

    let goal = Goal(title: "フルスタックエンジニアになる", detail: "", targetYear: 3, category: "キャリア")
    goal.progress = 0.3
    container.mainContext.insert(goal)

    let todo1 = TodoItem(title: "Java Silverの問題集を解く", isSchedule: false)
    let todo2 = TodoItem(title: "ポートフォリオのREADMEを書く", isSchedule: false)
    container.mainContext.insert(todo1)
    container.mainContext.insert(todo2)

    let cal = Calendar.current
    let schedule1 = TodoItem(title: "営業との打ち合わせ", isSchedule: true, scheduledAt: cal.date(bySettingHour: 10, minute: 0, second: 0, of: Date()), scheduledEnd: cal.date(bySettingHour: 11, minute: 0, second: 0, of: Date()))
    let schedule2 = TodoItem(title: "Java学習", isSchedule: true, scheduledAt: cal.date(bySettingHour: 14, minute: 0, second: 0, of: Date()), scheduledEnd: cal.date(bySettingHour: 16, minute: 0, second: 0, of: Date()))
    container.mainContext.insert(schedule1)
    container.mainContext.insert(schedule2)

    return HomeView()
        .modelContainer(container)
}
