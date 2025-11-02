//
//  MakeAndSelectView.swift
//  StellaMe
//
//  Created by JaeyoungLee on 4/24/25.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - galaxymodel에서 선언한 텍스트(여러개), 별 이미지 선택을 저장 및 넘어갈 수 있도록 함.
struct MakeAndSelectView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Binding var praiseText: String
    @Binding var isNewStarCreated: Bool
    
    @State private var selectedOption = "새로운 별 만들기"
    @State private var moveToGalaxyMakeView: Bool = false
    @State private var newGalaxyName: String = ""
    
    
    @Query private var galaxyMemory: [GalaxyModel]
    @Query private var starMemory: [StarModel]
    
    // 임시
    @State private var GalaxyText: String = ""
    @State private var selectedGalaxyImage: String = ""
    @State private var todayText: String = ""
    @State private var generatedPraise: String = ""
    @State private var showBottomTextView: Bool = false
    
    // 클로저
    var onSubmitPraise: (String) -> Void = { _ in }
    
    var dropDownOption: [String] {
        var options = ["새로운 별 만들기", "새로운 별자리 만들기"]
        options += galaxyMemory.map { $0.title }
        return options
    }
    let apiKey = OpenAIService.getAPIKey()
    var galaxyModel: GalaxyModel?
    var starModel: StarModel?
    
    var body: some View {
        ZStack {
            Image("BG")
                .resizable(resizingMode: .stretch)
                .ignoresSafeArea()
            VStack {
                Spacer()
                Spacer()
                
                
                HStack {
                    Text("별")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.yellow)
                        .multilineTextAlignment(.center)
                    Text("볼 일 없는 일상도")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                }
                HStack {
                    Text("여기에서는")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                    Text("별")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.yellow)
                        .multilineTextAlignment(.center)
                    Text("나요")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, -8.0)
                }
                
                Image("MakeAndSelectViewStar")
                    .resizable()
                    .frame(width: 200, height: 230)
                
                
                Spacer()
                
                
                TextField("오늘 무슨 일을 하셨나요?", text: $todayText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300, height: 40)
                
                
                
                
                // MARK: - 드롭다운 휠 형식 구현 로직
                Picker("selectOption", selection: $selectedOption) {
                    ForEach(dropDownOption, id: \.self) {
                        Text($0)
                            .foregroundColor(.white)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 300, height: 180)
                .onChange(of: selectedOption) {
                    if selectedOption == "새로운 별자리 만들기" {
                        moveToGalaxyMakeView = true
                    }
                }
                
                
                
                // MARK: - 나의 별자리로 보내기 버튼
                Button {
                    Task{
                        do {
                            let praise = try await OpenAIService.generatePraise(for: todayText)
                            onSubmitPraise(praise)
                            praiseText = praise
                            isNewStarCreated = true
                            dismiss()
                            // HomeView에 값 넘기고 dismiss() + isShowingAnimation 상태변수를 true로 바꿔줌
                            // TODO: praise를 CongratulationView로 넘겨서 UI에 표시
                        } catch {
                            print("API호출 실패: \(error.localizedDescription)")
                        }
                        
                        
                        
                        if selectedOption == "새로운 별 만들기" {
                            saveStar(text: todayText)
                        } else if let galaxy = galaxyMemory.first(where: { $0.title == selectedOption }) {
                            let newStar = StarModel(starText: todayText, date: Date(), galaxy: galaxy)
                            modelContext.insert(newStar)
                            try? modelContext.save()
                            print("\(galaxy.title)에 새로운 별 추가 완료")
                            dismiss()
                        }
                        if selectedOption == "새로운 별 만들기" {
                            saveStar(text: todayText)
                        } else if let galaxy = galaxyMemory.first(where: { $0.title == selectedOption }) {
                            let newStar = StarModel(starText: todayText, date: Date(), galaxy: galaxy)
                            modelContext.insert(newStar)
                            try? modelContext.save()
                            print("\(galaxy.title)에 새로운 별 추가 완료")
                            dismiss()
                        }

                        todayText = "" // 텍스트 입력창 초기화
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.yellow)
                        .frame(width: 150, height: 50)
                        .overlay {
                            Text("하늘에 수놓기")
                                .bold()
                                .foregroundStyle(.white)
                        }
                }
                .disabled(todayText.isEmpty)
                .padding(.top, 50.0)
                Spacer(minLength: 0)
            }
        }.sheet(isPresented: $showBottomTextView) {
            BottomTextView(praise: generatedPraise)
        }
        .ignoresSafeArea(.all)
        .sheet(isPresented: $moveToGalaxyMakeView) {
            GalaxyMakeView(newGalaxyName: $newGalaxyName, isPresented: $moveToGalaxyMakeView)
        }
        .onChange(of: moveToGalaxyMakeView) {
            if moveToGalaxyMakeView == false && !newGalaxyName.isEmpty {
                selectedOption = newGalaxyName
                newGalaxyName = "" // 하루 일과 보낸후 텍스트 입력창 초기화
                //                modelContext.insert(newGalaxy)
            }
        }.onAppear {
            if let key = OpenAIService.getAPIKey() {
                // print("API 키: \(key)")
            } else {
                print("API 키를 가져오지 못했습니다.")
            }
        }
    }
    
    
    func saveStar(text: String) {
        let newStar = StarModel(starText: text, date: Date(), galaxy: nil)
        modelContext.insert(newStar)
        do {
            print("\(text)가 저장되었어")
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving StarModel: \(error)")
        }
    }
}
// MARK: - submit 버튼을 누르면 homeView로 넘어가고 저장한 별자리 이미지를 homeview에 넘겨줌.

struct MakeAndSelectViewPreviewWrapper: View {
    @State var dummyPraise = "미리보기 칭찬"
    @State var dummyNewStarFlag = false

    var body: some View {
        MakeAndSelectView(
            praiseText: $dummyPraise,
            isNewStarCreated: $dummyNewStarFlag
        )
    }
}

#Preview {
    MakeAndSelectViewPreviewWrapper()
}
