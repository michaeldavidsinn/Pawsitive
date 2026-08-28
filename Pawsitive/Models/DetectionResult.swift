//
//  DetectionResult.swift
//  Pawsitive
//
//  Created by Michael David Sin on 21/08/26.
//

import Combine
import CoreML
import Foundation
import UIKit
import Vision

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

    func processFrame(_ pixelBuffer: CVPixelBuffer, isFrontCamera: Bool = false) {
        guard let visionModel = visionModel else { return }

        // 1. Catat waktu mulai
        let startTime = CFAbsoluteTimeGetCurrent()

        let request = VNCoreMLRequest(model: visionModel) {
            [weak self] request, error in
            // 2. Catat waktu selesai & hitung durasi
            let timeElapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
            print(
                "⚡ Core ML Inference Time: \(String(format: "%.2f", timeElapsed)) ms"
            )

            guard let self = self,
                let results = request.results
                    as? [VNRecognizedObjectObservation]
            else { return }

            DispatchQueue.main.async {
                self.detections = results.compactMap { observation in
                    guard let topClassification = observation.labels.first,
                        topClassification.confidence > 0.5
                    else { return nil }
                    var displayLabel = topClassification.identifier
                    if let index = Int(topClassification.identifier),
                        index < self.emotionLabels.count
                    {
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

        let orientation: CGImagePropertyOrientation = isFrontCamera ? .left : .right
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: orientation,
            options: [:]
        )
        try? handler.perform([request])
    }

    func processImage(_ image: UIImage) {
        guard let visionModel = visionModel,
              let cgImage = image.cgImage else { return }

        // Determine orientation
        let orientation: CGImagePropertyOrientation
        switch image.imageOrientation {
        case .up: orientation = .up
        case .down: orientation = .down
        case .left: orientation = .left
        case .right: orientation = .right
        case .upMirrored: orientation = .upMirrored
        case .downMirrored: orientation = .downMirrored
        case .leftMirrored: orientation = .leftMirrored
        case .rightMirrored: orientation = .rightMirrored
        @unknown default: orientation = .up
        }

        let startTime = CFAbsoluteTimeGetCurrent()

        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            let timeElapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
            print("⚡ Core ML Static Image Inference Time: \(String(format: "%.2f", timeElapsed)) ms")

            guard let self = self,
                let results = request.results as? [VNRecognizedObjectObservation] else { return }

            DispatchQueue.main.async {
                self.detections = results.compactMap { observation in
                    guard let topClassification = observation.labels.first,
                        topClassification.confidence > 0.5 else { return nil }
                    var displayLabel = topClassification.identifier
                    if let index = Int(topClassification.identifier),
                        index < self.emotionLabels.count {
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

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: orientation,
            options: [:]
        )
        try? handler.perform([request])
    }
}
