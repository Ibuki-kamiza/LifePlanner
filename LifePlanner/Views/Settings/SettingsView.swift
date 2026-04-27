//
//  SettingsView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var personalities: [AIPersonality]

    @State private var name: String = ""
    @State private var birthYear: Int = 2000
    @State private var occupation: String = ""
    @State private var aiName: String = "ライフコーチ"
    @State private var characterType: String = "counselor"
    @State private var tone: String = "gentle"
    @State private var language: String = "ja"
    @State private var isSaved: Bool = false

    let characterTypes = ["mentor": "メンター", "coach": "コーチ", "friend": "友達", "counselor": "カウンセラー"]
    let tones = ["gentle": "優しい", "friendly": "フレンドリー", "strict": "厳しめ"]
    let languages = ["ja": "日本語", "en": "英語"]
    let currentYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("プロフィール")) {
                    TextField("名前", text: $name)
                    Picker("生まれ年", selection: $birthYear) {
                        ForEach((1950...currentYear).reversed(), id: \.self) { year in
                            Text("\(year)年").tag(year)
                        }
                    }
                    TextField("職業・目標", text: $occupation)
                }

                Section(header: Text("AIアシスタント設定")) {
                    TextField("AIの名前", text: $aiName)
                    Picker("キャラクター", selection: $characterType) {
                        ForEach(characterTypes.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            Text(value).tag(key)
                        }
                    }
                    Picker("口調", selection: $tone) {
                        ForEach(tones.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            Text(value).tag(key)
                        }
                    }
                    Picker("言語", selection: $language) {
                        ForEach(languages.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            Text(value).tag(key)
                        }
                    }
                }

                Section {
                    Button(action: saveSettings) {
                        HStack {
                            Spacer()
                            Text(isSaved ? "保存しました ✓" : "保存する")
                                .fontWeight(.bold)
                                .foregroundColor(isSaved ? .green : .blue)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("設定")
            .onAppear(perform: loadSettings)
        }
    }

    private func loadSettings() {
        if let profile = profiles.first {
            name = profile.name
            birthYear = profile.birthYear
            occupation = profile.occupation
        }
        if let personality = personalities.first {
            aiName = personality.name
            characterType = personality.characterType
            tone = personality.tone
            language = personality.language
        }
    }

    private func saveSettings() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        if let profile = profiles.first {
            profile.name = name
            profile.birthYear = birthYear
            profile.occupation = occupation
        } else {
            let newProfile = UserProfile(name: name, birthYear: birthYear, occupation: occupation)
            modelContext.insert(newProfile)
        }

        if let personality = personalities.first {
            personality.name = aiName
            personality.characterType = characterType
            personality.tone = tone
            personality.language = language
        } else {
            let newPersonality = AIPersonality(name: aiName, characterType: characterType, tone: tone, language: language)
            modelContext.insert(newPersonality)
        }

        withAnimation {
            isSaved = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSaved = false
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserProfile.self, AIPersonality.self], inMemory: true)
}
