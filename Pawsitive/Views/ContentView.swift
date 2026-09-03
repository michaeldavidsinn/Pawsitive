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
                TabView {
                    HomeView(onStart: { currentScreen = .camera })
                        .tabItem {
                            Label("Scan", systemImage: "camera.fill")
                        }
                    
                    HistoryView()
                        .tabItem {
                            Label("Journal", systemImage: "book.fill")
                        }
                }
                .tint(Theme.gradientStart)
                
            case .camera:
                CameraCaptureScreen(
                    cameraManager: cameraManager,
                    onCapture: { capturedBuffer in
                        currentScreen = .loading
                        processCapturedFrame(buffer: capturedBuffer)
                    },
                    onPhotoSelected: { selectedImage in
                        currentScreen = .loading
                        processSelectedImage(uiImage: selectedImage)
                    },
                    onClose: {
                        currentScreen = .home
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

        autoreleasepool {
            let ciImage = CIImage(cvPixelBuffer: buffer)
            let context = CIContext(options: [.useSoftwareRenderer: false])
            
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                currentScreen = .camera
                return
            }
            
            let orientation: UIImage.Orientation = cameraManager.isFrontCamera ? .left : .right
            let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
  
            detector.processFrame(buffer, isFrontCamera: cameraManager.isFrontCamera)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentScreen = .result(image: uiImage, detections: detector.detections)
            }
        }
    }

    private func processSelectedImage(uiImage: UIImage) {
        detector.processImage(uiImage)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentScreen = .result(image: uiImage, detections: detector.detections)
        }
    }
}

#Preview {
    ContentView()
}
