import Foundation
import AVFoundation
import CoreImage
import UIKit

final class CameraHandler: NSObject, ObservableObject {
    @Published var frame: CGImage?
    @Published var isProcessing = false
    @Published var capturedImage: UIImage?
    
    private let captureSession = AVCaptureSession()
    private let context = CIContext()
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")
    private var videoOutput: AVCaptureVideoDataOutput?
    
    override init() {
        super.init()
        requestCameraAccess()
    }
    
    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupSession()
                }
            }
        default:
            break
        }
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.captureSession.canAddInput(input) else { return }
            
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high
            self.captureSession.addInput(input)
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            
            guard self.captureSession.canAddOutput(videoOutput) else { return }
            self.captureSession.addOutput(videoOutput)
            self.videoOutput = videoOutput
            
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    func capturePhoto() {
        guard let cgImage = frame else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.isProcessing = true
            let uiImage = UIImage(cgImage: cgImage)
            self?.capturedImage = uiImage
            self?.pauseCamera()
        }
    }
    
    func resumeCamera() {
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.capturedImage = nil
                self?.isProcessing = false
            }
        }
    }
    
    func pauseCamera() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    deinit {
        captureSession.stopRunning()
    }
}

extension CIImage {
    func oriented(_ orientation: CGImagePropertyOrientation) -> CIImage {
        self.oriented(forExifOrientation: Int32(orientation.rawValue))
    }
}

extension CameraHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let orientation = CGImagePropertyOrientation.right
        let image = CIImage(cvPixelBuffer: buffer).oriented(orientation)
        
        guard let cgImage = context.createCGImage(image, from: image.extent) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.frame = cgImage
        }
    }
}