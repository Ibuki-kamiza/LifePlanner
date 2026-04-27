//
//  UserProfile.swift
//  LifePlanner
//
import Foundation
import SwiftData

@Model
class UserProfile {
    var name: String
    var birthYear: Int
    var occupation: String
    var createdAt: Date

    init(name: String = "", birthYear: Int = 2000, occupation: String = "") {
        self.name = name
        self.birthYear = birthYear
        self.occupation = occupation
        self.createdAt = Date()
    }
}
