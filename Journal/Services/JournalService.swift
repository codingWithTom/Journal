//
//  JournalService.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-07-05.
//

import Foundation
import Combine

protocol JournalService {
  var journalsResource: AnyPublisher<[Journal], Never> { get }
  func saveJournal(_: Journal)
  func retrieveData()
  func getExistingCategories() -> [String]
}

final class JournalServiceAdapter: JournalService {
  static let shared = JournalServiceAdapter()
  
  private var fileURL: URL {
    let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return URL(fileURLWithPath: "journals", relativeTo: directory)
  }
  private var journals: [Journal] = [] {
    didSet {
      currentValueJournals.value = journals
    }
  }
  private let currentValueJournals = CurrentValueSubject<[Journal], Never>([])
  var journalsResource: AnyPublisher<[Journal], Never> {
    currentValueJournals.eraseToAnyPublisher()
  }
  
  func saveJournal(_ journal: Journal) {
    if let index = journals.firstIndex(where: { $0.id == journal.id }) {
      journals[index] = journal
    } else {
      journals.append(journal)
    }
    saveData()
  }
  
  func retrieveData() {
    if let data = try? Data(contentsOf: fileURL), let journals = try? JSONDecoder().decode([Journal].self, from: data) {
      self.journals = journals
    } else {
      self.journals = []
    }
  }
  
  func getExistingCategories() -> [String] {
    let categories = journals.flatMap { journal in journal.images.compactMap { $0.category } }
    return Array(Set(categories))
  }
}

private extension JournalServiceAdapter {
  func saveData() {
    do {
      let data = try JSONEncoder().encode(journals)
      try data.write(to: fileURL)
    } catch {
      print("Error saving file: \(error)")
    }
  }
}
