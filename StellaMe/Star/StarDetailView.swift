//
//  StarDetailView.swift
//  StellaMe
//
//  Created by JaeyoungLee on 4/25/25.
//

import SwiftUI
import SwiftData
import UIKit

struct StarDetailView: View {
    let star: StarModel
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var backgroundSettings: BackgroundSettings

    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            Image(backgroundSettings.currentBackgroundImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.5))

            VStack {
                Spacer().frame(height: 250)

                Image("Star1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .shadow(radius: 10)

                Spacer().frame(height: 20)

                Text(star.starText)
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.horizontal, 30)

                Spacer().frame(height: 20)

                VStack(spacing: 8) {
                    Text("생성 날짜")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    Text(star.date.formatted(date: .long, time: .shortened))
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)

                    Button("삭제", role: .destructive) {
                        showDeleteAlert = true
                    }
                    .padding(.top, 30)
                }

                Spacer()
            }
            .padding()
        }
        .alert("별을 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                deleteStarAndDismiss()
            }
        }
    }

    private func deleteStarAndDismiss() {
        star.modelContext?.delete(star)
        try? star.modelContext?.save()

        print("⭐️ 별 삭제 완료: \(star.starText)")
        onDelete?()
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StarModel.self, configurations: config)
    let context = container.mainContext
    let sampleStar = StarModel(starText: "미리보기 별", date: Date(), galaxy: nil)
    context.insert(sampleStar)
    return NavigationStack {
        StarDetailView(star: sampleStar)
            .modelContainer(container)
            .environmentObject(BackgroundSettings())
    }
}
