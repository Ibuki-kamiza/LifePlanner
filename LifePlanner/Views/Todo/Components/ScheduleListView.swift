//
//  ScheduleListView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct ScheduleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var todos: [TodoItem]

    @State private var showAddSchedule: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var selectedSchedule: TodoItem? = nil

    var schedulesForSelectedDate: [TodoItem] {
        let calendar = Calendar.current
        return todos.filter {
            $0.isSchedule &&
            calendar.isDate($0.scheduledAt ?? Date.distantPast, inSameDayAs: selectedDate)
        }
        .sorted { ($0.scheduledAt ?? Date.distantPast) < ($1.scheduledAt ?? Date.distantPast) }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                DatePicker(
                    "日付を選択",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                .background(AppStyle.cardBackground)

                List {
                    if schedulesForSelectedDate.isEmpty {
                        Text("この日の予定はありません")
                            .foregroundColor(AppStyle.secondaryText)
                    } else {
                        ForEach(0..<24, id: \.self) { hour in
                            let hourSchedules = schedulesForSelectedDate.filter {
                                Calendar.current.component(.hour, from: $0.scheduledAt ?? Date.distantPast) == hour
                            }
                            if !hourSchedules.isEmpty {
                                Section(header: Text(String(format: "%02d:00", hour))) {
                                    ForEach(hourSchedules) { schedule in
                                        ScheduleRowView(schedule: schedule)
                                            .contentShape(Rectangle())
                                            .onTapGesture { selectedSchedule = schedule }
                                            .swipeActions(edge: .trailing) {
                                                Button(role: .destructive) {
                                                    deleteSchedule(schedule)
                                                } label: {
                                                    Label("削除", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(AppStyle.background)
            }

            Button(action: { showAddSchedule = true }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.green)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showAddSchedule) {
            AddTodoView()
        }
        .sheet(item: $selectedSchedule) { schedule in
            TodoDetailView(item: schedule)
        }
    }

    private func deleteSchedule(_ schedule: TodoItem) {
        modelContext.delete(schedule)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: TodoItem.self, Goal.self,
        configurations: config
    )
    return ScheduleListView()
        .modelContainer(container)
}
