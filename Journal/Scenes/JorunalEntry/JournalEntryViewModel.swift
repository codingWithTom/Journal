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
  case content([UIImage])
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
}

private extension JournalEntryViewModel {
  func loadPhotos() async {
    let photoNames = self.journal.images
    let imagesActor = CollectionActor<UIImage>()
    await withTaskGroup(of: Void.self) { group in
      photoNames.forEach { photoName in
        group.addTask {
          let url = await self.dependencies.photosService.getURL(forName: photoName)
          guard
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
          else {
            return
          }
          await imagesActor.addValue(image)
        }
      }
    }
    let images = await imagesActor.values
    Task { @MainActor in
      photosState = .content(images)
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
    journal.images = journal.images + names
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
