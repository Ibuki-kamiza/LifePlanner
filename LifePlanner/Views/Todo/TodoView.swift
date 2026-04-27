//
//  TodoView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct TodoView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                AppStyle.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("表示切替", selection: $selectedTab) {
                        Text("☑️ Todo").tag(0)
                        Text("🗓 スケジュール").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    if selectedTab == 0 {
                        TodoListView()
                    } else {
                        ScheduleListView()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Todo")
                        .font(.headline)
                        .foregroundColor(AppStyle.accentBrown)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: TodoItem.self, Goal.self,
        configurations: config
    )
    return TodoView()
        .modelContainer(container)
}
