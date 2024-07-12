//
//  Journal.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-07-05.
//

import Foundation

struct Journal: Codable, Hashable {
  let id: UUID
  let text: String
}

extension Journal {
  init() {
    self.id = UUID()
    self.text = ""
  }
}
