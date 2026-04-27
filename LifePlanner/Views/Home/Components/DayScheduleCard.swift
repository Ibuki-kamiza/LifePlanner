//
//  DayScheduleCard.swift
//  LifePlanner
//
import SwiftUI

struct DayScheduleCard: View {
    let schedules: [TodoItem]

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

            if schedules.isEmpty {
                Text("今日の予定はありません")
                    .font(AppStyle.bodyFont)
                    .foregroundColor(AppStyle.secondaryText)
            } else {
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
                                    Text(schedule.title)
                                        .font(AppStyle.captionFont)
                                        .padding(4)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(4)
                                }
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
    DayScheduleCard(schedules: [])
}
