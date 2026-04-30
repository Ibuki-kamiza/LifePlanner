//
//  ReportView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct ReportView: View {
    @Query private var goals: [Goal]
    @Query private var todos: [TodoItem]
    @Query private var personalities: [AIPersonality]

    var body: some View {
        ZStack {
            AppStyle.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    HabitAnalysisCard(todos: todos)

                    FocusTimeCard(todos: todos)

                    IdealVsRealCard(goals: goals, todos: todos)

                    AIReportCard(
                        goals: goals,
                        todos: todos,
                        personality: personalities.first
                    )
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("レポート")
                    .font(.headline)
                    .foregroundColor(AppStyle.accentBrown)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Goal.self, TodoItem.self, AIPersonality.self,
        configurations: config
    )

    let goal1 = Goal(title: "フルスタックエンジニアになる", detail: "", targetYear: 3, category: "キャリア")
    goal1.progress = 0.3
    let goal2 = Goal(title: "年収600万円達成", detail: "", targetYear: 5, category: "お金")
    goal2.progress = 0.1
    container.mainContext.insert(goal1)
    container.mainContext.insert(goal2)

    let todo1 = TodoItem(title: "Java Silverの問題集を解く", isSchedule: false)
    todo1.isCompleted = true
    let todo2 = TodoItem(title: "ポートフォリオのREADMEを書く", isSchedule: false)
    container.mainContext.insert(todo1)
    container.mainContext.insert(todo2)

    let personality = AIPersonality(name: "ライフコーチ", characterType: "counselor", tone: "gentle", language: "ja")
    container.mainContext.insert(personality)

    return ReportView()
        .modelContainer(container)
}
