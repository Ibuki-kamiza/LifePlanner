//
//  DayScheduleCard.swift
//  LifePlanner
//
import SwiftUI

struct DayScheduleCard: View {
    let schedules: [TodoItem]
    let onTap: (TodoItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.green)
                Text("今日のスケジュール")
                    .font(AppStyle.headlineFont)
                Spacer()
                Text("\(schedules.count)件")
                    .font(AppStyle.captionFont)
                    .foregroundColor(AppStyle.secondaryText)
            }
            .padding(.bottom, 8)

            ForEach(0..<24, id: \.self) { hour in
                let hourSchedules = schedules.filter {
                    Calendar.current.component(.hour, from: $0.scheduledAt ?? Date.distantPast) == hour
                }
                HStack(alignment: .top, spacing: 8) {
                    Text(String(format: "%02d:00", hour))
                        .font(AppStyle.captionFont)
                        .foregroundColor(AppStyle.secondaryText)
                        .frame(width: 44, alignment: .trailing)

                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color(.systemGray4))

                    VStack(alignment: .leading, spacing: 2) {
                        if hourSchedules.isEmpty {
                            Color.clear.frame(height: 20)
                        } else {
                            ForEach(hourSchedules) { schedule in
                                HStack(spacing: 4) {
                                    if let end = schedule.scheduledEnd {
                                        let timeFormatter: DateFormatter = {
                                            let f = DateFormatter()
                                            f.dateFormat = "H:mm"
                                            return f
                                        }()
                                        Text("\(timeFormatter.string(from: schedule.scheduledAt ?? Date()))〜\(timeFormatter.string(from: end))")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                    }
                                    Text(schedule.title)
                                        .font(AppStyle.captionFont)
                                }
                                .padding(4)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(4)
                                .contentShape(Rectangle())
                                .onTapGesture { onTap(schedule) }
                            }
                        }
                    }
                }
            }
        }
        .padding(AppStyle.cardPadding)
        .background(AppStyle.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .padding(.horizontal, AppStyle.horizontalPadding)
    }
}

#Preview {
    let schedule = TodoItem(
        title: "営業との打ち合わせ",
        isSchedule: true,
        scheduledAt: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()),
        scheduledEnd: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())
    )
    DayScheduleCard(schedules: [schedule], onTap: { _ in })
}
