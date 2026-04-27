//
//  TodoListView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var todos: [TodoItem]

    @State private var showAddTodo: Bool = false
    @State private var selectedTodo: TodoItem? = nil

    var incompleteTodos: [TodoItem] {
        todos.filter { !$0.isSchedule && !$0.isCompleted }
    }

    var completedTodos: [TodoItem] {
        todos.filter { !$0.isSchedule && $0.isCompleted }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                if incompleteTodos.isEmpty && completedTodos.isEmpty {
                    Text("Todoはありません")
                        .foregroundColor(AppStyle.secondaryText)
                } else {
                    if !incompleteTodos.isEmpty {
                        Section(header: Text("未完了")) {
                            ForEach(incompleteTodos) { todo in
                                TodoRowView(todo: todo, onToggle: toggleTodo)
                                    .contentShape(Rectangle())
                                    .onTapGesture { selectedTodo = todo }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            deleteTodo(todo)
                                        } label: {
                                            Label("削除", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }

                    if !completedTodos.isEmpty {
                        Section(header: Text("完了済み")) {
                            ForEach(completedTodos) { todo in
                                TodoRowView(todo: todo, onToggle: toggleTodo)
                                    .contentShape(Rectangle())
                                    .onTapGesture { selectedTodo = todo }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            deleteTodo(todo)
                                        } label: {
                                            Label("削除", systemImage: "trash")
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

            Button(action: { showAddTodo = true }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showAddTodo) {
            AddTodoView()
        }
        .sheet(item: $selectedTodo) { todo in
            TodoDetailView(item: todo)
        }
    }

    private func toggleTodo(_ todo: TodoItem) {
        todo.isCompleted.toggle()
    }

    private func deleteTodo(_ todo: TodoItem) {
        modelContext.delete(todo)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: TodoItem.self, Goal.self,
        configurations: config
    )
    return TodoListView()
        .modelContainer(container)
}
