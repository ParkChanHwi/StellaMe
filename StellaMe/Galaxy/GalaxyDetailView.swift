//
//  GalaxyDetailView.swift
//  StellaMe
//
//  Created by JaeyoungLee on 4/24/25.

import SwiftUI
import SwiftData

struct GalaxyDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var backgroundSettings: BackgroundSettings
    @State private var showDeleteAlert = false
    @State private var starToDelete: StarModel? = nil
    @State private var showToast = false

    let galaxyModel: GalaxyModel

    var body: some View {
        ZStack {
            Image(backgroundSettings.currentBackgroundImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.5))

            VStack {
                Spacer().frame(height: 80)

                Image(galaxyModel.galaxyImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .shadow(radius: 10)

                Spacer().frame(height: 20)

                Text(galaxyModel.title)
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 5)

                Spacer().frame(height: 20)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(galaxyModel.stars.enumerated()), id: \.element.id) { index, star in
                            HStack {
                                Text(star.starText)
                                    .font(.body)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(star.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    starToDelete = star
                                    showDeleteAlert = true
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }

                            if index != galaxyModel.stars.count - 1 {
                                Divider()
                                    .background(Color.white.opacity(0.3))
                            }
                        }
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 5)
                    .padding(.horizontal, 40)
                }

                Spacer()
            }
            .padding()

            if showToast {
                VStack {
                    Spacer()
                    Text("삭제되었습니다")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.bottom, 30)
                }
                .transition(.opacity)
            }
        }
        .alert("정말 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                if let star = starToDelete {
                    modelContext.delete(star)
                    try? modelContext.save()

                    showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showToast = false
                    }
                }
            }
            Button("취소", role: .cancel) { }
        }
        .navigationTitle(galaxyModel.title)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GalaxyModel.self, StarModel.self, configurations: config)
    let context = container.mainContext

    let galaxy = GalaxyModel(title: "별자리1", galaxyImageName: "firstStar")
    let star1 = StarModel(starText: "별1", date: Date(), galaxy: galaxy)
    let star2 = StarModel(starText: "별2", date: Date(), galaxy: galaxy)

    context.insert(galaxy)
    context.insert(star1)
    context.insert(star2)

    return NavigationStack {
        GalaxyDetailView(galaxyModel: galaxy)
            .modelContainer(container)
            .environmentObject(BackgroundSettings())
    }
}
