//
//  JournalPhotosContainer.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-08-22.
//

import SwiftUI

struct JournalPhotosContainer<Content: View>: View {
  @ViewBuilder var content: Content
  
  private var randomRotation: Double {
    Double.random(in: -25 ... 25)
  }
  
  var body: some View {
    ForEach(sections: content) { section in
      if !section.header.isEmpty {
        section.header
      }
      LazyVGrid(columns: .init(repeating: .init(.flexible(minimum: 100, maximum: 300)), count: 3)) {
        ForEach(subviews: section.content) { subView in
          if subView.containerValues.isJournalPhoto {
            subView
              .padding()
              .background(
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color.black)
              )
              .rotationEffect(.degrees(randomRotation))
          } else {
            subView
          }
        }
      }
    }
  }
}

extension ContainerValues {
  @Entry var isJournalPhoto: Bool = false
}

extension View {
  func markViewAsJournalPhoto() -> some View {
    containerValue(\.isJournalPhoto, true)
  }
}
