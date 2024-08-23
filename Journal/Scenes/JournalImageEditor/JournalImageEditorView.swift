//
//  JournalImageEditorView.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-08-22.
//

import SwiftUI

struct JournalImageEditorView: View {
  @StateObject var viewModel: JournalImageEditorViewModel
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          HStack {
            Spacer()
            TextField(text: $viewModel.category) {
              Text("Image Category")
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            Spacer()
          }
          .padding(.bottom, 40)
          
          LazyVGrid(columns: .init(repeating: .init(.flexible(minimum: 50, maximum: 200)), count: 3)) {
            ForEach(viewModel.existingCategories, id: \.self) { category in
              Button(action: { viewModel.category = category }) {
                Text(category)
              }
              .buttonStyle(BorderedButtonStyle())
            }
          }
        }
      }
      .padding()
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: { viewModel.onSaveTapped() }) {
            Text("Save")
          }
        }
      }
    }
  }
}
