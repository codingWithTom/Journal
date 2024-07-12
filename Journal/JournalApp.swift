//
//  JournalApp.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-07-05.
//

import SwiftUI

@main
struct JournalApp: App {
  
  init() {
    JournalServiceAdapter.shared.retrieveData()
  }
  
  var body: some Scene {
    WindowGroup {
      JournalsListView()
    }
  }
}
