//
//  StarView.swift
//  StellaMe
//
//  Created by Hwi on 4/26/25.
//
// 클릭할 수 있는 객체로의 Star
import SwiftUI
import SwiftData

// StarView.swift
struct StarView: View {
    let star: StarModel
    @EnvironmentObject var backgroundSettings: BackgroundSettings

    var body: some View {
        VStack {
            Image("Star1")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    StarView(star: StarModel(starText: "안냥", date: Date()))
}
