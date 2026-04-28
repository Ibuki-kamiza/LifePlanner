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
        modelContext.insert(newGoal)
        dismiss()
    }
}

#Preview {
    AddGoalView()
        .modelContainer(for: [Goal.self], inMemory: true)
}
