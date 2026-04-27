//
//  TodoItem.swift
//  LifePlanner
//
import Foundation
import SwiftData

@Model
class TodoItem {
    var id: UUID
    var title: String
    var detail: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var isSchedule: Bool
    var scheduledAt: Date?
    var scheduledEnd: Date?
    var priority: Int
    var category: String
    var goalId: UUID?
    var zoomUrl: String
    var location: String

    init(title: String, detail: String = "", isSchedule: Bool = false, dueDate: Date? = nil, scheduledAt: Date? = nil, scheduledEnd: Date? = nil, category: String = "") {
        self.id = UUID()
        self.title = title
        self.detail = detail
        self.isCompleted = false
        self.createdAt = Date()
        self.dueDate = dueDate
        self.isSchedule = isSchedule
        self.scheduledAt = scheduledAt
        self.scheduledEnd = scheduledEnd
        self.priority = 0
        self.category = category
        self.goalId = nil
        self.zoomUrl = ""
        self.location = ""
    }
}
