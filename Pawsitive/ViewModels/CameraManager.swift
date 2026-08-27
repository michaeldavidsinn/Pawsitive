//
//  CameraManager.swift
//  Pawsitive
//
//  Created by Michael David Sin on 21/08/26.
//

import Foundation
import AVFoundation
import CoreImage
import Combine

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var currentBuffer: CVPixelBuffer?
    
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.captureSession.canAddInput(videoInput) else {
                print("⚠️ Kamera tidak tersedia.")
                self.captureSession.commitConfiguration()
                return
            }
            self.captureSession.addInput(videoInput)
            
            if self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.queue"))
            }
            
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        DispatchQueue.main.async {
            self.currentBuffer = pixelBuffer
        }
    }
    
    func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.captureSession.beginConfiguration()
            
            guard let currentInput = self.captureSession.inputs.first as? AVCaptureDeviceInput else {
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.removeInput(currentInput)
            
            let newPosition: AVCaptureDevice.Position = currentInput.device.position == .back ? .front : .back
            guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
                  let newInput = try? AVCaptureDeviceInput(device: newDevice),
                  self.captureSession.canAddInput(newInput) else {
                // Fallback to original input if failure
                self.captureSession.addInput(currentInput)
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.addInput(newInput)
            
            // Adjust video output connection for front camera mirroring if needed
            if let connection = self.videoOutput.connection(with: .video) {
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = (newPosition == .front)
                }
            }
            
            self.captureSession.commitConfiguration()
        }
    }
}
