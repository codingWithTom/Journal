//
//  CameraPreviewRepresentable.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-08-07.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraPreviewRepresentable: UIViewRepresentable {
  let session: AVCaptureSession
  
  func makeUIView(context: Context) -> CameraPreviewView {
    CameraPreviewView()
  }
  
  func updateUIView(_ uiView: CameraPreviewView, context: Context) {
    uiView.videoPreviewLayer.session = session
  }
}

final class CameraPreviewView: UIView {
  override class var layerClass: AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }
  
  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    return layer as! AVCaptureVideoPreviewLayer
  }
}
