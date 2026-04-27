//
//  ScheduleRowView.swift
//  LifePlanner
//
import SwiftUI

struct ScheduleRowView: View {
    let schedule: TodoItem

    var timeRangeText: String {
        guard let start = schedule.scheduledAt else { return "" }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "H:mm"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"

        let startText = timeFormatter.string(from: start)
        let startDate = dateFormatter.string(from: start)

        if let end = schedule.scheduledEnd {
            let endText = timeFormatter.string(from: end)
            let endDate = dateFormatter.string(from: end)
            if startDate == endDate {
                return "\(startDate)\n\(startText)〜\(endText)"
            } else {
                return "\(startDate) \(startText)\n〜\(endDate) \(endText)"
            }
        }
        return "\(startDate)\n\(startText)〜"
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(timeRangeText)
                    .font(AppStyle.captionFont)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .fixedSize()
                    .multilineTextAlignment(.center)
                Rectangle()
                    .frame(width: 2)
                    .foregroundColor(.green.opacity(0.3))
            }
            .frame(width: 60)

            VStack(alignment: .leading, spacing: 2) {
                Text(schedule.title)
                    .font(AppStyle.bodyFont)
                    .foregroundColor(AppStyle.primaryText)
                if !schedule.detail.isEmpty {
                    Text(schedule.detail)
                        .font(AppStyle.captionFont)
                        .foregroundColor(AppStyle.secondaryText)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let schedule = TodoItem(
        title: "営業との打ち合わせ",
        detail: "オンライン会議",
        isSchedule: true,
        scheduledAt: Date(),
        scheduledEnd: Calendar.current.date(byAdding: .hour, value: 2, to: Date())
    )
    ScheduleRowView(schedule: schedule)
}
