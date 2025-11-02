//
//  OnboardingLastView.swift
//  StellaMe
//
//  Created by JaeyoungLee on 4/29/25.
//

import SwiftUI

struct OnboardingLastView: View {
    let backgroundImage = ""
    let imageName: String
    let title: String
    let subtitle: String

    @Binding var isFirstLaunching: Bool

    var body: some View {
        ZStack {
            Image(backgroundImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)

            VStack(spacing: 20) {
                if !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea(.all)
                }

                Text(title)
                    .font(.title2)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)

                Button {
                    isFirstLaunching = false
                } label: {
                    Text("Start")
                        .fontWeight(.bold)
                        .frame(width: 200, height: 50)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



