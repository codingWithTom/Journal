//
//  JournalsListViewModel.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-07-05.
//

import Foundation
import Combine

@MainActor
final class JournalsListViewModel: ObservableObject {
  @Published var journals: [Journal] = []
  
  struct Dependencies {
    var journalsService: JournalService = JournalServiceAdapter.shared
  }
  
  private let dependencies: Dependencies
  private var subscriptions = Set<AnyCancellable>()
  
  init(dependencies: Dependencies = .init()) {
    self.dependencies = dependencies
    fetchJournals()
  }
  
  func createJournal() {
    dependencies.journalsService.saveJournal(Journal())
  }
}

private extension JournalsListViewModel {
  func fetchJournals() {
    dependencies.journalsService
      .journalsResource
      .receive(on: RunLoop.main)
      .sink { [weak self] in
        self?.journals = $0
      }
      .store(in: &subscriptions)
  }
}
