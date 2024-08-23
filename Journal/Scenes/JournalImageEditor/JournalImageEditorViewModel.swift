//
//  JournalImageEditorViewModel.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-08-22.
//

import Foundation

@MainActor
final class JournalImageEditorViewModel: ObservableObject, Identifiable {
  @Published var category: String
  
  var journalImage: JournalImage
  let existingCategories: [String]
  let onEditFinished: (JournalImage) -> Void
  
  init(journalImage: JournalImage,
       existingCategories: [String],
       onEditFinished: @escaping (JournalImage) -> Void) {
    self.journalImage = journalImage
    self.existingCategories = existingCategories
    self.onEditFinished = onEditFinished
    self.category = journalImage.category ?? ""
  }
  
  func onSaveTapped() {
    if !category.isEmpty {    
      journalImage.category = category
    }
    onEditFinished(journalImage)
  }
}
