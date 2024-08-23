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
  @State private var isShowingPhotos = false
  
  init(journal: Journal) {
    self._viewModel = StateObject(wrappedValue: JournalEntryViewModel(journal: journal))
  }
  
  var body: some View {
    ZStack {
      VStack {
        Text(viewModel.text)
        Spacer()
      }
      if isShowingPhotos {
        photosContent
          .padding(.top, 60)
      } else {
        VStack {
          Spacer()
          HStack {
            Spacer()
            Button(action: { withAnimation { isShowingPhotos = true } }) {
              Image(systemName: "circle.grid.3x3")
            }
            .padding([.trailing, .bottom], 40)
          }
        }
      }
    }
    .sheet(item: $viewModel.editorViewModel) {
      JournalImageEditorView(viewModel: $0)
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
    case .content(let imagesWithCategory):
      photos(with: imagesWithCategory)
    }
  }
  
  private func photos(with imagesWithCategory: [(String?, [(UIImage, JournalImage)])]) -> some View {
    ScrollView {
      JournalPhotosContainer {
        Text("Photos")
          .font(.headline)
        PhotosPicker(selection: $viewModel.selectedPhotos,
                     matching: .images) {
          Text("Add Photos")
        }
        ForEach(imagesWithCategory, id: \.0) { (category, tuple) in
          Section {
            ForEach(tuple.indices, id: \.self) { index in
              let (image, journalImage) = tuple[index]
              Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .onTapGesture {
                  viewModel.tappedImage(withJournalImage: journalImage)
                }
                .markViewAsJournalPhoto()
            }
          } header: {
            Text(category ?? "No Category")
              .font(.title2)
          }
        }
      }
      .padding(.horizontal)
    }
  }
}
