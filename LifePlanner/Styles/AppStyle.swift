//
//  AppStyle.swift
//  LifePlanner
//
import SwiftUI

struct AppStyle {
    // 背景色
    static let background = Color(red: 0.96, green: 0.93, blue: 0.88)
    static let cardBackground = Color.white.opacity(0.8)

    // テキストカラー
    static let primaryText = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let secondaryText = Color.gray
    static let accentBrown = Color(red: 0.4, green: 0.25, blue: 0.1)

    // フォント
    static let titleFont = Font.custom("Zapfino", size: 20)
    static let headlineFont = Font.headline
    static let bodyFont = Font.body
    static let captionFont = Font.caption

    // コーナーRadius
    static let cornerRadius: CGFloat = 12

    // パディング
    static let cardPadding: CGFloat = 16
    static let horizontalPadding: CGFloat = 16
}
