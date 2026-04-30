//
//  AddGoalView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var targetYear: Int = 5
    @State private var targetDate: Date = Calendar.current.date(byAdding: .year, value: 5, to: Date()) ?? Date()
    @State private var usesSpecificDate: Bool = false
    @State private var category: String = "キャリア"

    let categories = ["キャリア", "健康", "学習", "お金", "人間関係", "その他"]
    let years = Array(1...50)

    var body: some View {
        NavigationStack {
            ZStack {
                AppStyle.background
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("目標")) {
                        TextField("タイトル", text: $title)
                        TextField("詳細（任意）", text: $detail, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    Section(header: Text("達成目標")) {
                        Picker("指定方法", selection: $usesSpecificDate) {
                            Text("何年後").tag(false)
                            Text("日付指定").tag(true)
                        }
                        .pickerStyle(.segmented)

                        if usesSpecificDate {
                            DatePicker(
                                "達成目標日",
                                selection: $targetDate,
                                in: Date()...,
                                displayedComponents: .date
                            )
                        } else {
                            Picker("何年後", selection: $targetYear) {
                                ForEach(years, id: \.self) { year in
                                    Text("\(year)年後").tag(year)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                        }
                    }

                    Section(header: Text("カテゴリ")) {
                        Picker("カテゴリ", selection: $category) {
                            ForEach(categories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section {
                        Button(action: saveGoal) {
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
            .navigationTitle("目標を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }

    private func saveGoal() {
        let newGoal = Goal(
            title: title,
            detail: detail,
            targetYear: targetYear,
            category: category
        )
        if usesSpecificDate {
            newGoal.targetDate = targetDate
            newGoal.usesSpecificDate = true
            let years = Calendar.current.dateComponents([.year], from: Date(), to: targetDate).year ?? 0
            newGoal.targetYear = max(years, 1)
        }
        modelContext.insert(newGoal)
        dismiss()
    }
}

#Preview {
    AddGoalView()
        .modelContainer(for: [Goal.self], inMemory: true)
}
