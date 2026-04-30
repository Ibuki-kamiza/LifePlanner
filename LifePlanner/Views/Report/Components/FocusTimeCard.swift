//
//  FocusTimeCard.swift
//  LifePlanner
//
import SwiftUI

struct FocusTimeCard: View {
    let todos: [TodoItem]

    var hourlyActivity: [Int: Int] {
        var activity: [Int: Int] = [:]
        for todo in todos where todo.isCompleted {
            let hour = Calendar.current.component(.hour, from: todo.createdAt)
            activity[hour, default: 0] += 1
        }
        return activity
    }

    var peakHour: Int? {
        hourlyActivity.max(by: { $0.value < $1.value })?.key
    }

    var maxActivity: Int {
        hourlyActivity.values.max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                Text("集中時間帯の洞察")
                    .font(AppStyle.headlineFont)
            }

            if let peak = peakHour {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.purple)
                    Text("最も集中できる時間帯：\(peak):00〜\(peak + 1):00")
                        .font(AppStyle.bodyFont)
                        .fontWeight(.semibold)
                }
                .padding(8)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            } else {
                Text("まだデータが不足しています。Todoを完了すると分析できます。")
                    .font(AppStyle.captionFont)
                    .foregroundColor(AppStyle.secondaryText)
            }

            // 時間帯グラフ
            VStack(alignment: .leading, spacing: 4) {
                Text("時間帯別アクティビティ")
                    .font(AppStyle.captionFont)
                    .foregroundColor(AppStyle.secondaryText)

                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(0..<24, id: \.self) { hour in
                        let count = hourlyActivity[hour] ?? 0
                        let height = maxActivity > 0 ? CGFloat(count) / CGFloat(maxActivity) * 60 : 0

                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(hour == peakHour ? Color.purple : Color.purple.opacity(0.3))
                                .frame(width: 10, height: max(height, 2))

                            if hour % 6 == 0 {
                                Text("\(hour)")
                                    .font(.system(size: 8))
                                    .foregroundColor(AppStyle.secondaryText)
                            } else {
                                Text("")
                                    .font(.system(size: 8))
                            }
                        }
                    }
                }
                .frame(height: 80)
            }
        }
        .padding(AppStyle.cardPadding)
        .background(AppStyle.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .padding(.horizontal, AppStyle.horizontalPadding)
    }
}

#Preview {
    FocusTimeCard(todos: [])
}
