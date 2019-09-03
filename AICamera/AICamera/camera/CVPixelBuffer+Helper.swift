//
//  CVPixelBuffer+Helper.swift
//  AICamera
//
//  Created by taox on 9/2/19.
//  Copyright © 2019 taox. All rights reserved.
//

import Foundation
import Accelerate

extension CVPixelBuffer {
    func resize (_ width: Int, _ height: Int) -> [Float32]? {
        let w = CVPixelBufferGetWidth(self)
        let h = CVPixelBufferGetHeight(self)
        let pixelBufferType = CVPixelBufferGetPixelFormatType(self)
        assert(pixelBufferType == kCVPixelFormatType_32BGRA)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let bytesPerPixel = 4;
        let croppedImageSize = min(w, h);
        CVPixelBufferLockBaseAddress(self,.readOnly)
        let oriX = w>h ? (w-h)/2 : 0
        let oriY = h>w ? (h-w)/2 : 0
        guard let baseAddr = CVPixelBufferGetBaseAddress(self)?.advanced(by: oriY*bytesPerRow + oriX*bytesPerPixel) else {
            return nil
        }
        var inBuff  = vImage_Buffer(data: baseAddr, height: UInt(croppedImageSize), width: UInt(croppedImageSize), rowBytes: bytesPerRow)
        guard let dstData = malloc(width*height*bytesPerPixel) else { //dstData will be freed by releaseCallback
            return nil
        }
        var outBuff = vImage_Buffer(data: dstData, height: UInt(height), width: UInt(width), rowBytes: width*bytesPerPixel)
        let err = vImageScale_ARGB8888(&inBuff, &outBuff, nil, vImage_Flags(0))
        CVPixelBufferUnlockBaseAddress(self, .readOnly)
        if err != kvImageNoError {
            return nil;
        }
        let releaseCallback:CVPixelBufferReleaseBytesCallback = { _, pointer in
            if  pointer == pointer  {
                free(UnsafeMutableRawPointer(mutating: pointer))
            }
        }
        var dstPixelBuffer: CVPixelBuffer?
        let pixelType = CVPixelBufferGetPixelFormatType(self)
        let status = CVPixelBufferCreateWithBytes(nil, width, height, pixelType, dstData, width*4, releaseCallback, nil, nil, &dstPixelBuffer)
        if status != kCVReturnSuccess {
            free(dstData)
            return nil
        }
        var normalizedBuffer: [Float32] = [Float32](repeating: 0, count: width*height*3)
        //normalize the pixel buffer
        //see https://pytorch.org/hub/pytorch_vision_resnet/ for more detail
        for i in 0..<w*h {
            normalizedBuffer[i]         = ( Float32(dstData.load(fromByteOffset: i*4+2, as: UInt8.self)) / 255.0 - 0.485 ) / 0.229; //R
            normalizedBuffer[w*h+i]     = ( Float32(dstData.load(fromByteOffset: i*4+1, as: UInt8.self)) / 255.0 - 0.456 ) / 0.224; //G
            normalizedBuffer[w*h*2+i]   = ( Float32(dstData.load(fromByteOffset: i*4+0, as: UInt8.self)) / 255.0 - 0.406 ) / 0.225; //B
        }
        return normalizedBuffer;
    }
}
