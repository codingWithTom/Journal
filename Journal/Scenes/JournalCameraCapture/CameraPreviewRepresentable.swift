//
//  CameraPreviewRepresentable.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-08-07.
//

import SwiftUI
import UIKit
import AVFoundation
import AVKit

struct CameraPreviewRepresentable: UIViewRepresentable {
  let session: AVCaptureSession
  let onCapture: () -> Void
  
  func makeUIView(context: Context) -> CameraPreviewView {
    let view = CameraPreviewView()
    view.addInteraction(AVCaptureEventInteraction {
      if $0.phase == .ended {
        self.onCapture()
      }
    })
    return view
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
