//
//  SLMAdviceGenerator.swift
//  Pawsitive
//
//  Created by Michael David Sin on 26/08/26.
//

import Foundation
import UIKit

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
    
    /// Generasi saran AI secara dinamis menggunakan Gemini API
    func generateAdvice(for label: String, confidence: Float, image: UIImage? = nil) async -> String {
        // Jika API Key belum diset, langsung pakai fallback lokal agar aplikasi tidak macet
        guard apiKey != "YOUR_GEMINI_API_KEY" && !apiKey.isEmpty else {
            print("⚠️ Gemini API Key belum dikonfigurasi. Menggunakan fallback lokal.")
            return fallbackAdvice(for: label)
        }
        
        let prompt = """
        You are an expert dog behaviorist speaking directly to a dog owner in a professional and warm tone. 
        Analyze the provided image to identify the dog's breed and its current environment. 
        The dog's detected emotion is \(label) with \(Int(confidence * 100))% confidence. 

        Provide highly practical advice on how the owner should react right now based on the breed, environment, and emotion. 

        Guidelines:
        - Give ONE immediate, actionable step the owner can do.
        - If the breed is unclear, refer to the pet affectionately without guessing.
        - Do NOT start with robotic phrases like "Based on the image" or "I can see". Dive straight into the natural advice.
        - Keep it very concise (maximum 2-3 sentences). Write in English.
        """
        
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-lite-latest:generateContent?key=\(apiKey)") else {
            return fallbackAdvice(for: label)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60.0
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var parts: [[String: Any]] = [
            ["text": prompt]
        ]
        
        if let image = image {
            // Resize image to prevent massive payload size (max 800x800)
            let maxDimension: CGFloat = 800.0
            let size = image.size
            var newSize = size
            if size.width > maxDimension || size.height > maxDimension {
                let ratio = size.width / size.height
                if ratio > 1 {
                    newSize = CGSize(width: maxDimension, height: maxDimension / ratio)
                } else {
                    newSize = CGSize(width: maxDimension * ratio, height: maxDimension)
                }
            }
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let finalImage = resizedImage ?? image as UIImage?, let imageData = finalImage.jpegData(compressionQuality: 0.6) {
                let base64Image = imageData.base64EncodedString()
                parts.append([
                    "inline_data": [
                        "mime_type": "image/jpeg",
                        "data": base64Image
                    ]
                ])
            }
        }
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": parts
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
               let responseParts = content["parts"] as? [[String: Any]],
               let firstPart = responseParts.first,
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
        
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-lite-latest:generateContent?key=\(apiKey)") else {
            return "Error: Invalid URL"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60.0
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
