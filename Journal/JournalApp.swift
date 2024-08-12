//
//  JournalApp.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-07-05.
//

import SwiftUI
import AppIntents

@main
struct JournalApp: App {
  
  private let routingService: RoutingServiceAdapter
  
  init() {
    JournalServiceAdapter.shared.retrieveData()
    PhotosServiceAdapter.shared.initializeDirectory()
    let routingService = RoutingServiceAdapter.shared
    self.routingService =  routingService
    AppDependencyManager.shared.add(dependency: routingService)
  }
  
  var body: some Scene {
    WindowGroup {
      JournalsListView()
        .environment(routingService)
    }
  }
}
