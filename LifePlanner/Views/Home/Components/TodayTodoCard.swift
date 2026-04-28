//
//  TodayTodoCard.swift
//  LifePlanner
//
import SwiftUI

struct TodayTodoCard: View {
    let todos: [TodoItem]
    let onToggle: (TodoItem) -> Void
    let onTap: (TodoItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                Text("今日のTodo")
                    .font(AppStyle.headlineFont)
                Spacer()
                Text("\(todos.count)件")
                    .font(AppStyle.captionFont)
                    .foregroundColor(AppStyle.secondaryText)
            }
            if todos.isEmpty {
                Text("今日のTodoはありません")
                    .font(AppStyle.bodyFont)
                    .foregroundColor(AppStyle.secondaryText)
            } else {
                ForEach(todos) { todo in
                    HStack {
                        Button(action: { onToggle(todo) }) {
                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)

                        Text(todo.title)
                            .font(AppStyle.bodyFont)
                            .strikethrough(todo.isCompleted)
                            .foregroundColor(todo.isCompleted ? AppStyle.secondaryText : AppStyle.primaryText)

                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { onTap(todo) }
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
    TodayTodoCard(
        todos: [],
        onToggle: { _ in },
        onTap: { _ in }
    )
}
