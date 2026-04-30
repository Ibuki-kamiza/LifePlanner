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
    @State private var zoomUrl: String = ""
    @State private var location: String = ""
    @State private var selectedGoalId: UUID? = nil
    @State private var showCompletedAlert: Bool = false

    var linkedGoal: Goal? {
        guard let goalId = item.goalId else { return nil }
        return goals.first { $0.id == goalId }
    }

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
            .navigationTitle("詳細")
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
            .alert("完了しました", isPresented: $showCompletedAlert) {
                Button("OK") { dismiss() }
            } message: {
                if let goal = linkedGoal {
                    Text("「\(goal.title)」の進捗に反映されました")
                } else {
                    Text("お疲れ様でした！")
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if !isEditing && !item.isCompleted {
                    Button(action: completeItem) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("完了")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    // 詳細表示
    private var detailSection: some View {
        Group {
            Section(header: Text("予定")) {
                Text(item.title)
                    .font(AppStyle.bodyFont)
            }

            Section(header: Text("詳細")) {
                if item.detail.isEmpty {
                    Text("詳細なし")
                        .foregroundColor(AppStyle.secondaryText)
                } else {
                    Text(item.detail)
                        .font(AppStyle.bodyFont)
                }
            }

            if item.isSchedule {
                Section(header: Text("日時")) {
                    if let start = item.scheduledAt {
                        LabeledContent("開始", value: start.formatted(date: .abbreviated, time: .shortened))
                    }
                    if let end = item.scheduledEnd {
                        LabeledContent("終了", value: end.formatted(date: .abbreviated, time: .shortened))
                    }
                }

                Section(header: Text("場所・URL")) {
                    if item.location.isEmpty {
                        Text("場所なし")
                            .foregroundColor(AppStyle.secondaryText)
                    } else {
                        LabeledContent("場所", value: item.location)
                    }
                    if item.zoomUrl.isEmpty {
                        Text("Zoom URLなし")
                            .foregroundColor(AppStyle.secondaryText)
                    } else {
                        Link(destination: URL(string: item.zoomUrl) ?? URL(string: "https://")!) {
                            Label("Zoom URL", systemImage: "video.fill")
                                .foregroundColor(.blue)
                        }
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
                    LabeledContent("完了", value: item.isCompleted ? "完了" : "未完了")
                }
            }

            if !item.category.isEmpty {
                Section(header: Text("カテゴリ")) {
                    Text(item.category)
                }
            }

            if let goal = linkedGoal {
                Section(header: Text("紐づく目標")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.title)
                        ProgressView(value: goal.progress)
                            .accentColor(.blue)
                        Text("進捗 \(Int(goal.progress * 100))%")
                            .font(AppStyle.captionFont)
                            .foregroundColor(AppStyle.secondaryText)
                    }
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
            Section(header: Text("予定")) {
                TextField("タイトル", text: $title)
            }

            Section(header: Text("詳細")) {
                TextField("詳細（任意）", text: $detail, axis: .vertical)
                    .lineLimit(3...6)
            }

            if item.isSchedule {
                Section(header: Text("日時")) {
                    DatePicker("開始日時", selection: $scheduledAt, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("終了日時", selection: $scheduledEnd, in: scheduledAt..., displayedComponents: [.date, .hourAndMinute])
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
                        DatePicker("締め切り日", selection: $dueDate, displayedComponents: .date)
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
        }
    }

    private func completeItem() {
        item.isCompleted = true

        // 紐づく目標の進捗を更新
        if let goal = linkedGoal {
            let relatedTodos = goals.flatMap { _ in [] as [TodoItem] }
            _ = relatedTodos
            let increment = 0.05
            goal.progress = min(goal.progress + increment, 1.0)
        }

        showCompletedAlert = true
    }

    private func startEditing() {
        title = item.title
        detail = item.detail
        category = item.category
        zoomUrl = item.zoomUrl
        location = item.location
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
        item.zoomUrl = zoomUrl
        item.location = location
        if item.isSchedule {
            item.scheduledAt = scheduledAt
            item.scheduledEnd = scheduledEnd
        } else {
            item.dueDate = hasDueDate ? dueDate : nil
        }
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
        detail: "オンライン会議の詳細はSlackで確認",
        isSchedule: true,
        scheduledAt: Date(),
        scheduledEnd: Calendar.current.date(byAdding: .hour, value: 1, to: Date())
    )
    item.zoomUrl = "https://zoom.us/j/example"
    item.location = "オンライン"
    container.mainContext.insert(item)
    return TodoDetailView(item: item)
        .modelContainer(container)
}
