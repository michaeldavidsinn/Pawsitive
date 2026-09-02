//
//  VisionBreedDetector.swift
//  Pawsitive
//
//  Created by Michael David Sin on 02/09/26.
//

import Vision
import UIKit

struct VisionBreedDetector {
    
    /// Mendeteksi ras anjing secara presisi menggunakan Apple Vision taxonomy
    static func detectBreed(from image: UIImage) async -> String {
        // Fix 1: Konversi aman UIImage ke CGImage (menangani CIImage dari kamera)
        guard let cgImage = convertToCGImage(image) else {
            return "Pet"
        }
        
        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                guard error == nil,
                      let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: "Pet")
                    return
                }
                
                // Whitelist kategori ras anjing yang didukung oleh Apple Vision taxonomy
                let dogBreeds: Set<String> = [
                    "australian_shepherd", "basset", "beagle", "bernese_mountain",
                    "bichon", "bulldog", "chihuahua", "collie", "corgi",
                    "dachshund", "dalmatian", "doberman", "german_shepherd",
                    "greyhound", "hound", "husky", "irish_wolfhound",
                    "jack_russell_terrier", "malamute", "mastiff", "pitbull",
                    "pomeranian", "poodle", "pug", "retriever", "rottweiler",
                    "schnauzer", "setter", "sheepdog", "spaniel", "terrier",
                    "vizsla", "weimaraner"
                ]
                
                // 1. Cari ras anjing spesifik dengan tingkat confidence > 10%
                let specificBreedObservation = results.first { obs in
                    let id = obs.identifier.lowercased()
                    let matchesWhitelist = dogBreeds.contains { breed in
                        id.contains(breed)
                    }
                    return obs.confidence > 0.10 && matchesWhitelist
                }
                
                if let breedObs = specificBreedObservation {
                    let formattedBreed = formatBreedName(breedObs.identifier)
                    continuation.resume(returning: formattedBreed)
                    return
                }
                
                // 2. Fallback jika hanya terdeteksi anjing secara umum
                let isDogDetected = results.contains { obs in
                    let id = obs.identifier.lowercased()
                    return obs.confidence > 0.20 && (id.contains("dog") || id.contains("canine"))
                }
                
                if isDogDetected {
                    continuation.resume(returning: "Dog")
                } else {
                    continuation.resume(returning: "Pet")
                }
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: "Pet")
                }
            }
        }
    }
    
    /// Konversi UIImage ke CGImage secara fleksibel
    private static func convertToCGImage(_ image: UIImage) -> CGImage? {
        if let cgImage = image.cgImage {
            return cgImage
        }
        if let ciImage = image.ciImage {
            let context = CIContext()
            return context.createCGImage(ciImage, from: ciImage.extent)
        }
        return nil
    }
    
    /// Merapikan identifier taxonomy Vision (misal "golden_retriever, dog" -> "Golden Retriever")
    private static func formatBreedName(_ identifier: String) -> String {
        let cleanIdentifier = identifier.components(separatedBy: ",").first ?? identifier
        return cleanIdentifier
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
