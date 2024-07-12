//
//  JournalEntryView.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-07-12.
//

import SwiftUI
import PhotosUI

struct JournalEntryView: View {
  @StateObject private var viewModel: JournalEntryViewModel
  
  init(journal: Journal) {
    self._viewModel = StateObject(wrappedValue: JournalEntryViewModel(journal: journal))
  }
  
  var body: some View {
    HStack {
      VStack {
        Text(viewModel.text)
        Spacer()
      }
      Spacer()
      Divider()
      Spacer()
      photosContent
    }
  }
  
  @ViewBuilder
  private var photosContent: some View {
    switch viewModel.photosState {
    case .loading:
      VStack {
        Spacer()
        ProgressView()
          .tint(.accentColor)
          .padding()
        Spacer()
      }
    case .content(let images):
      photos(with: images)
    }
  }
  
  private func photos(with images: [UIImage]) -> some View {
    ScrollView {
      VStack {
        Text("Photos")
          .font(.headline)
        PhotosPicker(selection: $viewModel.selectedPhotos,
                     matching: .images) {
          Text("Add Photos")
        }
        
        ForEach(images.indices, id: \.self) { index in
          Image(uiImage: images[index])
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
        }
        Spacer()
      }
      .padding(.horizontal)
    }
  }
}
