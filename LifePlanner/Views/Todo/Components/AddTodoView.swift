//
//  AddTodoView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct AddTodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var goals: [Goal]

    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var isSchedule: Bool = false
    @State private var dueDate: Date = Date()
    @State private var scheduledAt: Date = Date()
    @State private var scheduledEnd: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    @State private var hasDueDate: Bool = false
    @State private var selectedGoalId: UUID? = nil
    @State private var category: String = ""
    @State private var zoomUrl: String = ""
    @State private var location: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppStyle.background
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("基本情報")) {
                        TextField("タイトル", text: $title)
                        TextField("詳細（任意）", text: $detail, axis: .vertical)
                            .lineLimit(3...6)
                        Picker("種類", selection: $isSchedule) {
                            Text("☑️ Todo").tag(false)
                            Text("🗓 スケジュール").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }

                    if isSchedule {
                        Section(header: Text("スケジュール設定")) {
                            DatePicker(
                                "開始日時",
                                selection: $scheduledAt,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            DatePicker(
                                "終了日時",
                                selection: $scheduledEnd,
                                in: scheduledAt...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                        }

                        Section(header: Text("場所・URL")) {
                            TextField("場所を追加", text: $location)
                            TextField("Zoom URL", text: $zoomUrl)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                        }
                    } else {
                        Section(header: Text("締め切り")) {
                            Toggle("締め切りを設定する", isOn: $hasDueDate)
                            if hasDueDate {
                                DatePicker(
                                    "締め切り日",
                                    selection: $dueDate,
                                    displayedComponents: .date
                                )
                            }
                        }
                    }

                    Section(header: Text("カテゴリ")) {
                        TextField("カテゴリ（任意）", text: $category)
                    }

                    if !goals.isEmpty {
                        Section(header: Text("目標と紐づける")) {
                            Picker("目標", selection: $selectedGoalId) {
                                Text("なし").tag(UUID?.none)
                                ForEach(goals) { goal in
                                    Text(goal.title).tag(UUID?.some(goal.id))
                                }
                            }
                        }
                    }

                    Section {
                        Button(action: saveTodo) {
                            HStack {
                                Spacer()
                                Text("保存する")
                                    .fontWeight(.bold)
                                    .foregroundColor(title.isEmpty ? .gray : .blue)
                                Spacer()
                            }
                        }
                        .disabled(title.isEmpty)
                    }
                }
            }
            .navigationTitle(isSchedule ? "スケジュール追加" : "Todo追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }

    private func saveTodo() {
        let newTodo = TodoItem(
            title: title,
            detail: detail,
            isSchedule: isSchedule,
            dueDate: hasDueDate ? dueDate : nil,
            scheduledAt: isSchedule ? scheduledAt : nil,
            scheduledEnd: isSchedule ? scheduledEnd : nil,
            category: category
        )
        newTodo.goalId = selectedGoalId
        newTodo.zoomUrl = zoomUrl
        newTodo.location = location
        modelContext.insert(newTodo)
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: TodoItem.self, Goal.self,
        configurations: config
    )
    return AddTodoView()
        .modelContainer(container)
}
