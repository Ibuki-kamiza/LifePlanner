//
//  OnboardingView.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep: Int = 0
    @State private var name: String = ""
    @State private var birthDate: Date = Date()
    @State private var occupation: String = ""
    @State private var aiName: String = "ライフコーチ"
    @State private var characterType: String = "counselor"
    @State private var tone: String = "gentle"

    let onComplete: () -> Void

    var canProceed: Bool {
        if currentStep == 1 {
            return !name.isEmpty
        }
        return true
    }

    var body: some View {
        ZStack {
            AppStyle.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ステップインジケーター
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color(red: 0.4, green: 0.25, blue: 0.1) : Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .animation(.easeInOut, value: currentStep)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)

                // コンテンツ
                TabView(selection: $currentStep) {
                    OnboardingStep1View()
                        .tag(0)

                    OnboardingStep2View(
                        name: $name,
                        birthDate: $birthDate,
                        occupation: $occupation
                    )
                    .tag(1)

                    OnboardingStep3View(
                        aiName: $aiName,
                        characterType: $characterType,
                        tone: $tone
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                // ボタン
                VStack(spacing: 12) {
                    Button(action: handleNext) {
                        HStack {
                            Spacer()
                            Text(currentStep == 2 ? "はじめる" : "次へ")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Image(systemName: currentStep == 2 ? "checkmark" : "arrow.right")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(
                            canProceed ?
                            Color(red: 0.4, green: 0.25, blue: 0.1) :
                            Color.gray.opacity(0.5)
                        )
                        .cornerRadius(14)
                    }
                    .disabled(!canProceed)
                    .padding(.horizontal, 32)

                    if currentStep > 0 {
                        Button(action: { currentStep -= 1 }) {
                            Text("戻る")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func handleNext() {
        if currentStep < 2 {
            withAnimation {
                currentStep += 1
            }
        } else {
            saveAndComplete()
        }
    }

    private func saveAndComplete() {
        let profile = UserProfile(
            name: name,
            birthDate: birthDate,
            occupation: occupation
        )
        modelContext.insert(profile)

        let personality = AIPersonality(
            name: aiName.isEmpty ? "ライフコーチ" : aiName,
            characterType: characterType,
            tone: tone,
            language: "ja"
        )
        modelContext.insert(personality)

        onComplete()
    }
}

#Preview {
    OnboardingView(onComplete: {})
        .modelContainer(for: [UserProfile.self, AIPersonality.self], inMemory: true)
}
