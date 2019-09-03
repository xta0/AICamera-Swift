//
//  CameraPreview.swift
//  AICamera
//
//  Created by taox on 9/2/19.
//  Copyright © 2019 taox. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreview: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("AVCaptureVideoPreviewLayer is expected");
        }
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return previewLayer.session
        }
        set {
            previewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

}
