//
//  CameraSessionManager.swift
//  AICamera
//
//  Created by taox on 9/2/19.
//  Copyright © 2019 taox. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraSession: class {
    func cameraDidReceivePixelBuffer(_ data: CVPixelBuffer)
    func cameraPermissionDenied()
    func cameraSetupFailed()
    func cameraSessionWasInterrupted()
}
class CameraSessionManager: NSObject {
    
    weak var delegate: CameraSession?
    
    init(previewView: CameraPreview) {
        self.previewView = previewView
        super.init()
        session.sessionPreset = .high
        previewView.session = session
        previewView.previewLayer.connection?.videoOrientation = .portrait
        previewView.previewLayer.videoGravity = .resizeAspectFill
        
        
    }
    func startSession(){
        
    }
    func stopSession(){
        
    }
    private let session: AVCaptureSession = AVCaptureSession()
    private let previewView: CameraPreview

}
