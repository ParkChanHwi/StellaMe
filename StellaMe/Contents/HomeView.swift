//
//  HomeView.swift
//  StellaMe
//
//  Created by JaeyoungLee on 4/24/25.
//

import SwiftUI
import SwiftData
import Lottie

struct HomeView: View {
    @AppStorage("_isFirstLaunching") var isFirstLaunching: Bool = true
    @AppStorage("hasSeenTooltips") var hasSeenTooltips: Bool = false
    @State private var showTooltips = false
    @State private var isNewStarCreated = false
    @State private var praiseText = ""
    @State private var refreshTrigger = false
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var backgroundSettings: BackgroundSettings
    @Query var StarMemoryes: [StarModel]
    @Query var GalaxyMemoryes: [GalaxyModel]
    
    var body: some View {
        if isFirstLaunching {
            OnboardingTabView(isFristLauncing: $isFirstLaunching)
        }
        
        else {
            GeometryReader { geometry in
                ZStack {
                    Image(backgroundSettings.currentBackgroundImage)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    // MARK: 칭찬 뷰 및 애니메이션
                    if isNewStarCreated {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                        
                        GeometryReader { geometry in
                            VStack(spacing: 0) {
                                VStack(spacing: 12) {
                                    Text("✨ 새로운 별이 생성되었어요!")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Text(praiseText)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.horizontal, 24)
                                .frame(height: geometry.size.height * 0.3)
                                
                                Spacer()
                                
                                BunnyView(fileName: "starbunny")
                                    .frame(width: 250, height: 250)
                                    .offset(y: geometry.size.height * 0.05)
                                
                                Spacer(minLength: geometry.safeAreaInsets.bottom)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.opacity)
                        }
                    }
                    else {
                        existingHomeContent(geometry: geometry)
                    }
                }
            }
            .onChange(of: isNewStarCreated) { newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation {
                            isNewStarCreated = false
                        }
                    }
                }
            }
            .id(refreshTrigger)
            .onAppear {
                if !hasSeenTooltips {
                        showTooltips = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                showTooltips = false
                                hasSeenTooltips = true
                            }
                        }
                    }
                print("현재 별 개수: \(StarMemoryes.count)")
                print("[HomeView] modelContext: \(ObjectIdentifier(modelContext))")
            }
        }
    }
    
    @ViewBuilder
    func existingHomeContent(geometry: GeometryProxy) -> some View {
        let galaxyLinkedStarIDs: Set<UUID> = Set(
            GalaxyMemoryes.flatMap { $0.stars.map { $0.id } }
        )
        let independentStars = StarMemoryes.filter { !galaxyLinkedStarIDs.contains($0.id) }

        
        ForEach(independentStars.shuffled().prefix(5)) { star in
            NavigationLink(
                destination: StarDetailView(
                    star: star,
                    onDelete: {
                        refreshTrigger.toggle()
                        print("⭐️ HomeView 트리거로 새로고침됨")
                    }
                )
                .environmentObject(backgroundSettings)
                .modelContainer(modelContext.container)
            ) {
                StarView(star: star)
            }
            .position(x: CGFloat.random(in: 0...geometry.size.width),
                      y: CGFloat.random(in: 0...geometry.size.height / 2))
        }
        
        ForEach(GalaxyMemoryes) { galaxyMemory in
            NavigationLink(destination: GalaxyDetailView(galaxyModel: galaxyMemory)
                .environmentObject(backgroundSettings)) {
                    Image(galaxyMemory.galaxyImageName)
                        .resizable()
                        .frame(width: 180, height: 180)
                }
                .position(x: CGFloat.random(in: 0...geometry.size.width),
                          y: CGFloat.random(in: 0...geometry.size.height / 2))
        }
        
        ZStack {
            if showTooltips {
                Group {
                    Text("여기서 별을 만들 수 있어요!")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .offset(x: geometry.size.width * -0.32, y: geometry.size.height * 0.17)

                    Text("여기서 배경을 바꿔보세요!")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .offset(x: geometry.size.width * 0.32, y: geometry.size.height * 0.15)
                }
                .transition(.opacity)
            }
            
            NavigationLink(destination:
                            MakeAndSelectView(
                                praiseText: $praiseText,
                                isNewStarCreated: $isNewStarCreated,
                                onSubmitPraise: { praise in
                                    self.praiseText = praise
                                    withAnimation {
                                        self.isNewStarCreated = true
                                    }
                                }
                            ).modelContainer(modelContext.container)
            ){
                Image("locketStar")
                    .resizable()
                    .frame(width: 97, height: 146)
                    .rotationEffect(.degrees(-10))
            }
            .offset(x: geometry.size.width * -0.32, y: geometry.size.height * 0.25)
            
            BunnyView(fileName: "bunny")
                .frame(width: 300, height: 300)
                .offset(y: geometry.size.height * 0.20)
                .allowsHitTesting(false)
            
            Button {
                refreshTrigger.toggle()
            }
            label: {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.orange)
                    .frame(width: 120, height: 50)
                    .overlay {
                        Text("별 위치 재설정")
                            .bold()
                            .foregroundStyle(.bar)
                    }
            }
            .offset(y: geometry.size.height * 0.38)
            
            
            NavigationLink(destination: SettingView().environmentObject(backgroundSettings)) {
                Image("backgroundSetting")
                    .resizable()
                    .frame(width: 80, height: 130)
                    .rotationEffect(.degrees(10))
            }
            .offset(x: geometry.size.width * 0.32, y: geometry.size.height * 0.23)
        }
    }
}
struct HomeViewPreviewWrapper: View {
    var body: some View {
        NavigationStack {
            HomeView()
                .modelContainer(previewContainer)
                .environmentObject(BackgroundSettings())
        }
    }
    
    var previewContainer: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: StarModel.self, GalaxyModel.self, configurations: config)
        let context = container.mainContext
        
        let previewStar = StarModel(starText: "헛둘", date: Date())
        context.insert(previewStar)
        
        let previewGalaxy = GalaxyModel(
            title: "파운데이션 마지막날",
            galaxyImageName: "yellow"
        )

        let star1 = StarModel(starText: "헛둘", date: Date(), galaxy: previewGalaxy)
        let star2 = StarModel(starText: "ddd", date: Date(), galaxy: previewGalaxy)

        context.insert(previewGalaxy)
        context.insert(star1)
        context.insert(star2)


        context.insert(previewGalaxy)
        
        try! context.save()
        return container
    }
}

#Preview {
    HomeViewPreviewWrapper()
}
