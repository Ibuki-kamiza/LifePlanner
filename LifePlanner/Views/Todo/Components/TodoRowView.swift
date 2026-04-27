//
//  TodoRowView.swift
//  LifePlanner
//
import SwiftUI

struct TodoRowView: View {
    let todo: TodoItem
    let onToggle: (TodoItem) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: { onToggle(todo) }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundColor(todo.isCompleted ? .gray : .blue)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title)
                    .font(AppStyle.bodyFont)
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? AppStyle.secondaryText : AppStyle.primaryText)
                if let dueDate = todo.dueDate {
                    Text(dueDate, style: .date)
                        .font(AppStyle.captionFont)
                        .foregroundColor(AppStyle.secondaryText)
                }
            }

            Spacer()

            if todo.priority > 0 {
                priorityBadge
            }
        }
        .padding(.vertical, 4)
    }

    private var priorityBadge: some View {
        let colors: [Color] = [.clear, .green, .orange, .red]
        let labels = ["", "低", "中", "高"]
        return Text(labels[min(todo.priority, 3)])
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(colors[min(todo.priority, 3)].opacity(0.2))
            .cornerRadius(4)
    }
}

#Preview {
    TodoRowView(
        todo: TodoItem(title: "Java Silverの問題集を解く", isSchedule: false),
        onToggle: { _ in }
    )
}
