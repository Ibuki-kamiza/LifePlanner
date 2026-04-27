//
//  TodoDetailView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct TodoDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var goals: [Goal]

    @Bindable var item: TodoItem

    @State private var isEditing: Bool = false
    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var scheduledAt: Date = Date()
    @State private var scheduledEnd: Date = Date()
    @State private var dueDate: Date = Date()
    @State private var hasDueDate: Bool = false
    @State private var category: String = ""
    @State private var selectedGoalId: UUID? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AppStyle.background
                    .ignoresSafeArea()

                Form {
                    if isEditing {
                        editingSection
                    } else {
                        detailSection
                    }
                }
            }
            .navigationTitle(item.isSchedule ? "スケジュール詳細" : "Todo詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(isEditing ? "保存" : "編集") {
                        if isEditing {
                            saveChanges()
                        } else {
                            startEditing()
                        }
                    }
                }
            }
        }
    }

    // 詳細表示
    private var detailSection: some View {
        Group {
            Section(header: Text("基本情報")) {
                LabeledContent("タイトル", value: item.title)
                if !item.detail.isEmpty {
                    LabeledContent("詳細", value: item.detail)
                }
                if !item.category.isEmpty {
                    LabeledContent("カテゴリ", value: item.category)
                }
            }

            if item.isSchedule {
                Section(header: Text("スケジュール")) {
                    if let start = item.scheduledAt {
                        LabeledContent("開始", value: start.formatted(date: .abbreviated, time: .shortened))
                    }
                    if let end = item.scheduledEnd {
                        LabeledContent("終了", value: end.formatted(date: .abbreviated, time: .shortened))
                    }
                }
            } else {
                Section(header: Text("締め切り")) {
                    if let due = item.dueDate {
                        LabeledContent("締め切り", value: due.formatted(date: .abbreviated, time: .omitted))
                    } else {
                        Text("締め切りなし")
                            .foregroundColor(AppStyle.secondaryText)
                    }
                }
                Section(header: Text("状態")) {
                    LabeledContent("完了", value: item.isCompleted ? "✅ 完了" : "未完了")
                }
            }

            if let goalId = item.goalId,
               let goal = goals.first(where: { $0.id == goalId }) {
                Section(header: Text("紐づく目標")) {
                    Text(goal.title)
                }
            }

            Section {
                Button(role: .destructive) {
                    modelContext.delete(item)
                    dismiss()
                } label: {
                    HStack {
                        Spacer()
                        Text("削除する")
                        Spacer()
                    }
                }
            }
        }
    }

    // 編集フォーム
    private var editingSection: some View {
        Group {
            Section(header: Text("基本情報")) {
                TextField("タイトル", text: $title)
                TextField("詳細（任意）", text: $detail)
                TextField("カテゴリ（任意）", text: $category)
            }

            if item.isSchedule {
                Section(header: Text("スケジュール設定")) {
                    DatePicker("開始日時", selection: $scheduledAt, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("終了日時", selection: $scheduledEnd, in: scheduledAt..., displayedComponents: [.date, .hourAndMinute])
                }
            } else {
                Section(header: Text("締め切り")) {
                    Toggle("締め切りを設定する", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("締め切り日", selection: $dueDate, displayedComponents: .date)
                    }
                }
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
        }
    }

    private func startEditing() {
        title = item.title
        detail = item.detail
        category = item.category
        scheduledAt = item.scheduledAt ?? Date()
        scheduledEnd = item.scheduledEnd ?? Date()
        dueDate = item.dueDate ?? Date()
        hasDueDate = item.dueDate != nil
        selectedGoalId = item.goalId
        isEditing = true
    }

    private func saveChanges() {
        item.title = title
        item.detail = detail
        item.category = category
        item.scheduledAt = item.isSchedule ? scheduledAt : item.scheduledAt
        item.scheduledEnd = item.isSchedule ? scheduledEnd : item.scheduledEnd
        item.dueDate = hasDueDate ? dueDate : nil
        item.goalId = selectedGoalId
        isEditing = false
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: TodoItem.self, Goal.self,
        configurations: config
    )
    let item = TodoItem(
        title: "営業との打ち合わせ",
        detail: "オンライン会議",
        isSchedule: true,
        scheduledAt: Date(),
        scheduledEnd: Calendar.current.date(byAdding: .hour, value: 1, to: Date())
    )
    container.mainContext.insert(item)
    return TodoDetailView(item: item)
        .modelContainer(container)
}
