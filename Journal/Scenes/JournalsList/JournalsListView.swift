//
//  JournalsListView.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-07-05.
//

import SwiftUI

struct JournalsListView: View {
  @StateObject private var viewModel = JournalsListViewModel()
  var body: some View {
    NavigationStack {
      ZStack {
        ScrollView {
          VStack(spacing: 20) {
            Text("Your journey")
              .font(.largeTitle)
            journals
            Spacer()
          }
          .padding()
        }
        addButton
      }
    }
  }
  
  private var colors = [Color.orange, .red, .blue, .green, .brown, .white]
  
  private var journals: some View {
    LazyVGrid(columns: Array.init(repeating: .init(.flexible(minimum: 100, maximum: 400)),
                                  count: 3),
              spacing: 20) {
      ForEach(Array(viewModel.journals.enumerated()), id: \.1.id) { (index, journal) in
        RoundedRectangle(cornerRadius: 20)
          .fill(colors[index % colors.count])
          .frame(height: 90)
          .overlay(
            RoundedRectangle(cornerRadius: 20)
              .stroke(Color.black, lineWidth: 2)
          )
      }
    }
  }
  
  private var addButton: some View {
    HStack {
      Spacer()
      VStack {
        Spacer()
        Button(action: { viewModel.createJournal() }) {
          Image(systemName: "plus")
        }
        .buttonStyle(BorderedButtonStyle())
      }
    }
    .padding()
  }
}
