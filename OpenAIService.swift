//
//  OpenAIService.swift
//  StellaMe
//
//  Created by 박찬휘 on 5/8/25.
//

import Foundation

enum OpenAIService {
    static func getAPIKey() -> String? {
        // Info.plist 대신 환경변수에서 가져오기
        ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    }
    
    static func generatePraise(for text: String) async throws -> String {
        guard let apiKey = getAPIKey() else {
            throw NSError(domain: "APIKeyError", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "API 키가 없습니다. Xcode Scheme → Environment Variables를 확인하세요."
            ])
        }
        
        let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let systemPrompt = "사용자가 한 일에 대해 진심 어린 칭찬 한마디를 해줘. 짧고 간결하게, 인간적인 톤으로."

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": text]
            ],
            "max_tokens": 50
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)

        // 디버깅용: 원문 출력
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            print("응답 원문: \(json)")
        }

        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return response.choices.first?.message.content ?? "정말 잘했어요!"
    }
}

struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        let message: Message
    }
    struct Message: Decodable {
        let role: String
        let content: String
    }
    let choices: [Choice]
}
