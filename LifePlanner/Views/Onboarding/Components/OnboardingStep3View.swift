//
//  OnboardingStep3View.swift
//  LifePlanner
//
import SwiftUI

struct OnboardingStep3View: View {
    @Binding var aiName: String
    @Binding var characterType: String
    @Binding var tone: String

    let characterTypes = ["mentor": "メンター", "coach": "コーチ", "friend": "友達", "counselor": "カウンセラー"]
    let tones = ["gentle": "優しい", "friendly": "フレンドリー", "strict": "厳しめ"]

    var characterDescription: String {
        switch characterType {
        case "mentor": return "経験豊富な先輩として導いてくれます"
        case "coach": return "目標達成に向けて背中を押してくれます"
        case "friend": return "気軽に話せる友達として寄り添います"
        case "counselor": return "優しく丁寧にサポートしてくれます"
        default: return ""
        }
    }

    var toneDescription: String {
        switch tone {
        case "gentle": return "穏やかで丁寧な言葉で話しかけます"
        case "friendly": return "フランクで親しみやすい口調です"
        case "strict": return "厳しくも的確なアドバイスをします"
        default: return ""
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)

                Text("AIアシスタント設定")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.4, green: 0.25, blue: 0.1))

                Text("あなただけのAIを設定しましょう")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            VStack(spacing: 20) {
                // AI名前
                VStack(alignment: .leading, spacing: 6) {
                    Text("AIの名前")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    TextField("例：ライフコーチ", text: $aiName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4)
                }

                // キャラクター選択
                VStack(alignment: .leading, spacing: 8) {
                    Text("キャラクター")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(characterTypes.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            Button(action: { characterType = key }) {
                                VStack(spacing: 4) {
                                    Text(characterIcon(key))
                                        .font(.title2)
                                    Text(value)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(characterType == key ? Color(red: 0.4, green: 0.25, blue: 0.1) : Color.white)
                                .foregroundColor(characterType == key ? .white : AppStyle.primaryText)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 4)
                            }
                        }
                    }

                    Text(characterDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }

                // 口調選択
                VStack(alignment: .leading, spacing: 8) {
                    Text("口調")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)

                    HStack(spacing: 8) {
                        ForEach(tones.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            Button(action: { tone = key }) {
                                Text(value)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(tone == key ? Color(red: 0.4, green: 0.25, blue: 0.1) : Color.white)
                                    .foregroundColor(tone == key ? .white : AppStyle.primaryText)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 4)
                            }
                        }
                    }

                    Text(toneDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    private func characterIcon(_ type: String) -> String {
        switch type {
        case "mentor": return "🎓"
        case "coach": return "💪"
        case "friend": return "😊"
        case "counselor": return "🤝"
        default: return "✨"
        }
    }
}

#Preview {
    OnboardingStep3View(
        aiName: .constant("ライフコーチ"),
        characterType: .constant("counselor"),
        tone: .constant("gentle")
    )
}
