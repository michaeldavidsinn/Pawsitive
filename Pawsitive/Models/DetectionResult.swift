//
//  DetectionResult.swift
//  Pawsitive
//
//  Created by Michael David Sin on 21/08/26.
//

import Foundation
import Vision
import CoreML
import Combine
import UIKit

struct DetectionResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    let boundingBox: CGRect
}

class Detector: ObservableObject {
    @Published var detections: [DetectionResult] = []
    
    private var visionModel: VNCoreMLModel?
    
    private let emotionLabels = ["alert", "angry", "happy"]
    
    init() {
        setupModel()
    }
    
    private func setupModel() {
        do {
            let config = MLModelConfiguration()
            let coreMLModel = try best(configuration: config)
            visionModel = try VNCoreMLModel(for: coreMLModel.model)
        } catch {
            print("⚠️ Gagal memuat model Core ML: \(error)")
        }
    }
    
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        guard let visionModel = visionModel else { return }
        
        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            guard let self = self, let results = request.results as? [VNRecognizedObjectObservation] else { return }
            
            DispatchQueue.main.async {
                self.detections = results.compactMap { observation in
                    // Ambil label teratas
                    guard let topClassification = observation.labels.first else { return nil }
                    
                    // Filter confidence threshold (hanya ambil hasil di atas 50%)
                    guard topClassification.confidence > 0.5 else { return nil }
                    
                    // Rapikan penamaan label jika mengembalikan angka/indeks
                    var displayLabel = topClassification.identifier
                    if let index = Int(topClassification.identifier), index < self.emotionLabels.count {
                        displayLabel = self.emotionLabels[index]
                    }
                    
                    return DetectionResult(
                        label: displayLabel,
                        confidence: topClassification.confidence,
                        boundingBox: observation.boundingBox
                    )
                }
            }
        }
        
        // Atur agar orientasi gambar sesuai kamera HP
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        try? handler.perform([request])
    }
}
