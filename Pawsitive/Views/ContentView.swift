//
//  ContentView.swift
//  Pawsitive
//
//  Created by Michael David Sin on 21/08/26.
//

import SwiftUI

enum AppScreen {
    case home
    case camera
    case loading
    case result(image: UIImage, detections: [DetectionResult])
}

struct ContentView: View {
    @State private var currentScreen: AppScreen = .home
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var detector = Detector()
    
    var body: some View {
        ZStack {
            switch currentScreen {
            case .home:
                HomeView(onStart: { currentScreen = .camera })
                
            case .camera:
                CameraCaptureScreen(
                    cameraManager: cameraManager,
                    onCapture: { capturedBuffer in
                        currentScreen = .loading
                        processCapturedFrame(buffer: capturedBuffer)
                    }
                )
                
            case .loading:
                LoadingView()
                
            case .result(let image, let detections):
                ResultView(
                    image: image,
                    detections: detections,
                    onRetake: { currentScreen = .camera },
                    onGoHome: { currentScreen = .home }
                )
            }
        }
    }
    
    private func processCapturedFrame(buffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            currentScreen = .camera
            return
        }
        
        let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
        
        detector.processFrame(buffer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            currentScreen = .result(image: uiImage, detections: detector.detections)
        }
    }
}
