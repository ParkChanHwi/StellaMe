//
//  BottomTextView.swift
//  StellaMe
//
//  Created by 박찬휘 on 5/11/25.
//

import SwiftUI

struct BottomTextView: View {
    let praise: String
    var body: some View {
        VStack(spacing: 16) {
            Text("🎉 오늘도 해냈어요!")
                .font(.title2)
                .bold()
            Text(praise)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(16)
    }
}

struct BottomTextViewPreviewWrapper: View {
    @State var dummyPraise = "미리보기 칭찬"

    var body: some View {
        BottomTextView(
            praise: dummyPraise
        )
    }
}

#Preview {
    BottomTextViewPreviewWrapper()
}

