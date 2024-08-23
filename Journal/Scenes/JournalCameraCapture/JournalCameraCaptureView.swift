//
//  JournalCameraCaptureView.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-08-07.
//

import SwiftUI

struct JournalCameraCaptureView: View {
  @StateObject private var viewModel: JournalCameraCaptureViewModel
  
  init(isPresenting: Binding<Bool>) {
    self._viewModel = StateObject(wrappedValue: JournalCameraCaptureViewModel(isPresenting: isPresenting))
  }
  
  var body: some View {
    VStack {
      Button(action: { Task { await viewModel.saveToJournal() } }) {
        Image(systemName: "tray.and.arrow.down")
          .frame(width: 50, height: 50)
      }
      Text("Take pictures that you want on your entry")
      CameraPreviewRepresentable(session: viewModel.cameraSession) {
        viewModel.takePicture()
      }
      if viewModel.isLoading {
        ProgressView()
      } else {
        Button(action: { viewModel.takePicture() }) {
          Image(systemName: "camera.aperture")
            .frame(width: 60, height: 60)
        }
      }
      ScrollView(.horizontal) {
        HStack {
          ForEach(viewModel.images.indices, id: \.self) { index in
            Image(uiImage: UIImage(data: viewModel.images[index]) ?? UIImage())
              .resizable()
              .frame(width: 40, height: 40)
              .aspectRatio(contentMode: .fit)
          }
        }
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
  }
}
