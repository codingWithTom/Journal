//
//  JournalEntryViewModel.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-07-12.
//

import Foundation
import SwiftUI
import PhotosUI

enum PhotosState {
  case loading
  case content([(String?, [(UIImage, JournalImage)])])
}

@MainActor
final class JournalEntryViewModel: ObservableObject {
  struct Dependencies {
    var photosService: PhotosService = PhotosServiceAdapter.shared
    var journalService: JournalService = JournalServiceAdapter.shared
  }
  
  private let dependencies: Dependencies
  
  var journal: Journal
  var text: String {
    guard !journal.text.isEmpty else {
      return "This journal entry is empty :("
    }
    return journal.text
  }
  @Published var editorViewModel: JournalImageEditorViewModel?
  @Published var photosState: PhotosState = .loading
  @Published var selectedPhotos: [PhotosPickerItem] = [] {
    didSet {
      photosState = .loading
      Task { await savePhotos() }
    }
  }
  
  init(journal: Journal, dependencies: Dependencies = .init()) {
    self.journal = journal
    self.dependencies = dependencies
    Task { await loadPhotos() }
  }
  
  func tappedImage(withJournalImage journalImage: JournalImage) {
    guard let index = journal.images.firstIndex(where: { $0.name == journalImage.name }) else { return }
    let journalImage = journal.images[index]
    let existingCateories = dependencies.journalService.getExistingCategories()
    editorViewModel = JournalImageEditorViewModel(
      journalImage: journalImage, existingCategories: existingCateories
    ) { [weak self] in
      guard var journal = self?.journal else { return }
      journal.images[index] = $0
      self?.dependencies.journalService.saveJournal(journal)
      self?.journal = journal
      self?.editorViewModel = nil
    }
  }
}

private extension JournalEntryViewModel {
  func loadPhotos() async {
    let photoImages = self.journal.images
    let imagesActor = CollectionActor<(UIImage, JournalImage)>()
    await withTaskGroup(of: Void.self) { group in
      photoImages.forEach { journalPhoto in
        group.addTask {
          let url = await self.dependencies.photosService.getURL(forName: journalPhoto.name)
          guard
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
          else {
            return
          }
          await imagesActor.addValue((image, journalPhoto))
        }
      }
    }
    let images = await imagesActor.values
    let imagesWithCategory = images.group(by: \.1.category)
    Task { @MainActor in
      photosState = .content(imagesWithCategory.map { ($0.0, $0.1) })
    }
  }
  
  func savePhotos() async {
    let photoNamesActor = CollectionActor<String>()
    await withTaskGroup(of: Void.self) { group in
      for photoItem in selectedPhotos {
        group.addTask {
          guard let name = await self.savePhoto(photoItem) else { return }
          await photoNamesActor.addValue(name)
        }
      }
    }
    let names = await photoNamesActor.values
    let journalImages = names.map { JournalImage(name: $0) }
    journal.images = journal.images + journalImages
    dependencies.journalService.saveJournal(journal)
    await loadPhotos()
  }
  
  func savePhoto(_ photoItem: PhotosPickerItem) async -> String? {
    let name: String? = await withCheckedContinuation { continuation in
      photoItem.loadTransferable(type: Data.self) { [weak self] result in
        guard
          case let .success(data) = result,
          let data
        else {
          continuation.resume(returning: nil)
          return
        }
        do {
          let photoName = UUID().uuidString
          try self?.dependencies.photosService.saveImageData(data, withName: photoName)
          continuation.resume(returning: photoName)
        } catch {
          print("Error saving image data \(error)")
          continuation.resume(returning: nil)
        }
      }
    }
    return name
  }
}

actor CollectionActor<T> {
  var values: [T] = []
  
  func addValue(_ value: T) {
    values.append(value)
  }
}

extension Array {
  func group<Value: Hashable>(
    by keypath: KeyPath<Element, Value>) -> [(Value, [Element])] {
      var groups: [Value: [Element]] = [:]
      for element in self {
        let value = element[keyPath: keypath]
        if let group = groups[value] {
          groups[value] = group + [element]
        } else {
          groups[value] = [element]
        }
      }
      
      return groups.map { key, value in (key, value)}
    }
}
