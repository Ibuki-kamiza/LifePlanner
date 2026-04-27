//
//  AIPersonality.swift
//  LifePlanner
//
import Foundation
import SwiftData

@Model
class AIPersonality {
    var name: String
    var characterType: String
    var tone: String
    var language: String

    init(name: String = "ライフコーチ", characterType: String = "mentor", tone: String = "friendly", language: String = "ja") {
        self.name = name
        self.characterType = characterType
        self.tone = tone
        self.language = language
    }
}
