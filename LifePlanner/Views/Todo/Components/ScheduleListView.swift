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

    var allScheduleDates: Set<String> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return Set(todos.filter { $0.isSchedule }.compactMap {
            guard let date = $0.scheduledAt else { return nil }
            return formatter.string(from: date)
        })
    }

    var currentMonth: Date {
        Calendar.current.startOfDay(for: selectedDate)
    }

    var daysInMonth: [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))
        else { return [] }

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }

    var firstWeekday: Int {
        let calendar = Calendar.current
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))
        else { return 0 }
        return (calendar.component(.weekday, from: firstDay) - 1)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // カレンダーヘッダー
                calendarHeader

                // 曜日ヘッダー
                weekdayHeader

                // 日付グリッド
                calendarGrid

                Divider()

                // 選択日のスケジュール一覧
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
            .background(AppStyle.background)

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

    // カレンダーヘッダー（月ナビゲーション）
    private var calendarHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(AppStyle.accentBrown)
            }
            Spacer()
            Text(monthTitle)
                .font(.headline)
                .foregroundColor(AppStyle.primaryText)
            Spacer()
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppStyle.accentBrown)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(AppStyle.cardBackground)
    }

    // 曜日ヘッダー
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(day == "日" ? .red : day == "土" ? .blue : AppStyle.secondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 4)
        .background(AppStyle.cardBackground)
    }

    // 日付グリッド
    private var calendarGrid: some View {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
            // 空白
            ForEach(0..<firstWeekday, id: \.self) { _ in
                Color.clear.frame(height: 60)
            }

            // 日付
            ForEach(daysInMonth, id: \.self) { date in
                let dateStr = formatter.string(from: date)
                let hasSchedule = allScheduleDates.contains(dateStr)
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(date)
                let daySchedules = todos.filter {
                    $0.isSchedule &&
                    calendar.isDate($0.scheduledAt ?? Date.distantPast, inSameDayAs: date)
                }

                VStack(spacing: 2) {
                    // 日付
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 28, height: 28)
                        } else if isToday {
                            Circle()
                                .stroke(Color.blue, lineWidth: 1.5)
                                .frame(width: 28, height: 28)
                        }
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 14))
                            .fontWeight(isToday ? .bold : .regular)
                            .foregroundColor(
                                isSelected ? .white :
                                isToday ? .blue :
                                calendar.component(.weekday, from: date) == 1 ? .red :
                                calendar.component(.weekday, from: date) == 7 ? .blue :
                                AppStyle.primaryText
                            )
                    }
                    .frame(width: 28, height: 28)

                    // 予定表示（最大2件）
                    VStack(spacing: 1) {
                        ForEach(daySchedules.prefix(2)) { schedule in
                            Text(schedule.title)
                                .font(.system(size: 8))
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .padding(.horizontal, 2)
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(2)
                        }
                        if daySchedules.count > 2 {
                            Text("他\(daySchedules.count - 2)件")
                                .font(.system(size: 8))
                                .foregroundColor(AppStyle.secondaryText)
                        }
                    }
                    .frame(height: 24)
                }
                .frame(height: 60)
                .background(isSelected ? Color.blue.opacity(0.05) : Color.clear)
                .onTapGesture { selectedDate = date }
            }
        }
        .background(AppStyle.cardBackground)
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: selectedDate)
    }

    private func previousMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }

    private func nextMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
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
    let cal = Calendar.current
    let schedule1 = TodoItem(title: "営業打ち合わせ", isSchedule: true, scheduledAt: cal.date(bySettingHour: 10, minute: 0, second: 0, of: Date()), scheduledEnd: cal.date(bySettingHour: 11, minute: 0, second: 0, of: Date()))
    let schedule2 = TodoItem(title: "Java学習", isSchedule: true, scheduledAt: cal.date(bySettingHour: 14, minute: 0, second: 0, of: Date()), scheduledEnd: cal.date(bySettingHour: 16, minute: 0, second: 0, of: Date()))
    container.mainContext.insert(schedule1)
    container.mainContext.insert(schedule2)
    return ScheduleListView()
        .modelContainer(container)
}
