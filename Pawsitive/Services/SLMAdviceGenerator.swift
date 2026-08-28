//
//  SLMAdviceGenerator.swift
//  Pawsitive
//
//  Created by Michael David Sin on 26/08/26.
//

import Foundation

actor SLMAdviceGenerator {
    
    static let shared = SLMAdviceGenerator()
    
    // Membaca API Key dari Secrets.plist agar aman dari git
    private var apiKey: String {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String],
              let key = plist["GEMINI_API_KEY"], !key.isEmpty else {
            return ""
        }
        return key
    }
    
    private(set) var isReady = true
    
    private init() {}
    
    /// Generasi saran AI secara dinamis menggunakan Gemini 3.6 Flash API
    func generateAdvice(for label: String, confidence: Float) async -> String {
        // Jika API Key belum diset, langsung pakai fallback lokal agar aplikasi tidak macet
        guard apiKey != "YOUR_GEMINI_API_KEY" && !apiKey.isEmpty else {
            print("⚠️ Gemini API Key belum dikonfigurasi. Menggunakan fallback lokal.")
            return fallbackAdvice(for: label)
        }
        
        let prompt = "You are an expert dog behaviorist. The dog's detected emotion is \(label) with \(Int(confidence * 100))% confidence. Give 1 short, warm, and highly practical advice sentence for the owner on how to react to their dog right now. Write it in English and keep it brief (max 15 words)."
        
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=\(apiKey)") else {
            return fallbackAdvice(for: label)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10.0
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "maxOutputTokens": 1000,
                "temperature": 0.7
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Gemini API Error response: \(errorString)")
                }
                return fallbackAdvice(for: label)
            }
            
            // Parsing output JSON dari Gemini
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                
                let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return cleanedText.isEmpty ? fallbackAdvice(for: label) : cleanedText
            }
            
            return fallbackAdvice(for: label)
        } catch {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && (nsError.code == NSURLErrorNotConnectedToInternet || nsError.code == NSURLErrorDataNotAllowed) {
                return "No internet connection. Please check your network to get dynamic AI advice."
            }
            return fallbackAdvice(for: label)
        }
    }
    
    // MARK: - Fallback
    
    /// Saran statis jika internet mati atau API key belum dipasang
    private func fallbackAdvice(for label: String) -> String {
        switch label.lowercased() {
        case "happy":
            return "Your dog is in a great mood! This is a perfect time for bonding, playing fetch, or practicing new commands with treats."
        case "angry":
            return "Give your dog some space and reduce environmental stressors. Avoid direct eye contact and let them calm down naturally."
        case "alert":
            return "Your dog has noticed something in their surroundings. Observe what caught their attention and maintain a calm, reassuring posture."
        default:
            return "Keep interactions gentle and predictable. Observe your pet's body language to ensure they feel safe and comfortable."
        }
    }
    
    // MARK: - Test API Connection
    
    /// Fungsi pengujian untuk memverifikasi koneksi API Gemini
    func testGenerate(prompt: String) async -> String {
        guard apiKey != "YOUR_GEMINI_API_KEY" && !apiKey.isEmpty else {
            return "Test Fallback: (API Key belum dikonfigurasi)"
        }
        
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=\(apiKey)") else {
            return "Error: Invalid URL"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10.0
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "maxOutputTokens": 1000,
                "temperature": 0.5
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return "Error: HTTP \( (response as? HTTPURLResponse)?.statusCode ?? 0 )"
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return "Error: Gagal parsing JSON"
        } catch {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && (nsError.code == NSURLErrorNotConnectedToInternet || nsError.code == NSURLErrorDataNotAllowed) {
                return "Error: No Internet Connection"
            }
            return "Error: \(error.localizedDescription)"
        }
    }
}
