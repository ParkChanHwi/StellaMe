//
//  OnboardingPageView.swift
//  StellaMe
//
//  Created by JaeyoungLee on 4/29/25.
//

import SwiftUI

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let subtitle: String
    
    
    var body: some View {
            VStack {
                Image(imageName)
                Text(title)
                Text(subtitle)
            }
       
    }
}

#Preview("Onboarding 전체") {
    struct PreviewWrapper: View {
        @State var firstLaunch = true
        var body: some View {
            OnboardingTabView(isFristLauncing: $firstLaunch)
        }
    }

    return PreviewWrapper()
}
