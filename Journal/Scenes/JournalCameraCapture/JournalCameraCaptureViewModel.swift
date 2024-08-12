//
//  JournalCameraCaptureViewModel.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-08-07.
//

import Foundation
import SwiftUI
import AVFoundation

@MainActor
final class JournalCameraCaptureViewModel: NSObject, ObservableObject {
  struct Dependencies {
    var journalService: JournalService = JournalServiceAdapter.shared
    var photoService: PhotosService = PhotosServiceAdapter.shared
  }
  
  private var dependencies: Dependencies = .init()
  @Published var images: [Data] = []
  @Published var isLoading: Bool = false
  @Binding var isPresenting: Bool
  let cameraSession: AVCaptureSession
  private var photoOutput: AVCapturePhotoOutput?
  
  init(isPresenting: Binding<Bool>) {
    self.cameraSession = AVCaptureSession()
    self._isPresenting = isPresenting
    super.init()
  }
  
  func onAppear() {
    Task {
      guard await checkAuthorization() else { return }
      startCameraSession()
    }
  }
  
  func takePicture() {
    photoOutput?.capturePhoto(with: .init(), delegate: self)
  }
  
  func saveToJournal() async {
    isLoading = true
    let photoNamesActor = CollectionActor<String>()
    await withTaskGroup(of: Void.self) { group in
      for photoData in images {
        group.addTask {
          let name = UUID().uuidString
          do {
            try await self.dependencies.photoService.saveImageData(photoData, withName: name)
          } catch {
            print("Error saving photo \(error.localizedDescription)")
          }
          await photoNamesActor.addValue(name)
        }
      }
    }
    let names = await photoNamesActor.values
    var journal = Journal()
    journal.images = names
    dependencies.journalService.saveJournal(journal)
    isPresenting = false
  }
}

private extension JournalCameraCaptureViewModel {
  func checkAuthorization() async -> Bool {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    if status == .authorized {
      return true
    } else if status == .notDetermined {
      let authorizationGiven = await AVCaptureDevice.requestAccess(for: .video)
      return authorizationGiven
    } else {
      return false
    }
  }
  
  func startCameraSession() {
    cameraSession.beginConfiguration()
    
    let captureDevice: AVCaptureDevice
    
    if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
      captureDevice = device
    } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
      captureDevice = device
    } else {
      fatalError("Missed expected camera")
    }
    
    guard
      let videoDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
      cameraSession.canAddInput(videoDeviceInput)
    else {
      return
    }
    cameraSession.addInput(videoDeviceInput)
    
    let photoOutput = AVCapturePhotoOutput()
    guard cameraSession.canAddOutput(photoOutput) else { return }
    cameraSession.sessionPreset = .photo
    cameraSession.addOutput(photoOutput)
    
    cameraSession.commitConfiguration()
    self.photoOutput = photoOutput
    Task.detached {
      await self.cameraSession.startRunning()
    }
  }
}

extension JournalCameraCaptureViewModel: AVCapturePhotoCaptureDelegate {
  nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                               didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
    if let photoData = photo.fileDataRepresentation() {
      Task { @MainActor in
        self.images.append(photoData)
      }
    }
  }
}
