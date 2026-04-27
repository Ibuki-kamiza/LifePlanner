//
//  GeminiService.swift
//  LifePlanner
//
import Foundation

class GeminiService {
    static let shared = GeminiService()

    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String ?? ""
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

    private init() {}

    func generate(prompt: String, personality: AIPersonality? = nil) async throws -> String {
        let systemPrompt = buildSystemPrompt(personality: personality)
        let fullPrompt = systemPrompt + "\n\n" + prompt

        let url = URL(string: "\(endpoint)?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": fullPrompt]
                    ]
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let candidates = json?["candidates"] as? [[String: Any]]
        let content = candidates?.first?["content"] as? [String: Any]
        let parts = content?["parts"] as? [[String: Any]]
        let text = parts?.first?["text"] as? String

        return text ?? "応答を取得できませんでした"
    }

    private func buildSystemPrompt(personality: AIPersonality?) -> String {
        guard let p = personality else {
            return "あなたは人生目標をサポートするAIアシスタントです。日本語で回答してください。"
        }

        let toneText: String
        switch p.tone {
        case "strict": toneText = "厳しく的確に"
        case "gentle": toneText = "優しく丁寧に"
        default: toneText = "フレンドリーに"
        }

        let characterText: String
        switch p.characterType {
        case "coach": characterText = "コーチ"
        case "friend": characterText = "友達"
        case "counselor": characterText = "カウンセラー"
        default: characterText = "メンター"
        }

        return "あなたの名前は\(p.name)です。ユーザーの\(characterText)として\(toneText)アドバイスしてください。\(p.language == "ja" ? "日本語" : "英語")で回答してください。"
    }
}
