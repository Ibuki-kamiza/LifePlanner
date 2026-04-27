//
//  Goal.swift
//  LifePlanner
//
import Foundation
import SwiftData

@Model
class Goal {
    var id: UUID
    var title: String
    var detail: String
    var targetYear: Int
    var category: String
    var isCompleted: Bool
    var createdAt: Date
    var progress: Double

    init(title: String, detail: String, targetYear: Int, category: String) {
        self.id = UUID()
        self.title = title
        self.detail = detail
        self.targetYear = targetYear
        self.category = category
        self.isCompleted = false
        self.createdAt = Date()
        self.progress = 0.0
    }
}
