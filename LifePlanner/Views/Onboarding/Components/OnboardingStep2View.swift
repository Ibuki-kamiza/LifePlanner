
//
//  OnboardingStep2View.swift
//  LifePlanner
//
import SwiftUI

struct OnboardingStep2View: View {
    @Binding var name: String
    @Binding var birthDate: Date
    @Binding var occupation: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.4, green: 0.25, blue: 0.1))

                Text("プロフィール設定")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.4, green: 0.25, blue: 0.1))

                Text("あなたのことを教えてください")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("お名前")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    TextField("例：田中 一樹", text: $name)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("生年月日")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    DatePicker(
                        "",
                        selection: $birthDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("職業・目標（任意）")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    TextField("例：エンジニア志望", text: $occupation)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }
}

#Preview {
    OnboardingStep2View(
        name: .constant(""),
        birthDate: .constant(Date()),
        occupation: .constant("")
    )
}
