//
//  UserProfile.swift
//  LifePlanner
//
import Foundation
import SwiftData

@Model
class UserProfile {
    var name: String
    var birthDate: Date
    var occupation: String
    var createdAt: Date

    init(name: String = "", birthDate: Date = Date(), occupation: String = "") {
        self.name = name
        self.birthDate = birthDate
        self.occupation = occupation
        self.createdAt = Date()
    }
}

