//
//  JournalsListView.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-07-05.
//

import SwiftUI

struct JournalsListView: View {
  @StateObject var viewModel = JournalsListViewModel()
  @Environment(RoutingServiceAdapter.self) private var routingService
  
  var body: some View {
    @Bindable var routingService = self.routingService
    NavigationStack {
      ZStack {
        ScrollView {
          VStack(spacing: 20) {
            HStack {
              Text("Your journey")
                .font(.largeTitle)
              Spacer()
              Button(action: { viewModel.tappedCameraButton() }) {
                ZStack {
                  Image(systemName: "book.pages.fill")
                    .offset(x: -10, y: -10)
                  Image(systemName: "camera.fill")
                    .offset(x: 10, y: 10)
                }
              }
            }
            journals
            Spacer()
          }
          .padding()
        }
        addButton
      }
      .navigationDestination(for: Journal.self, destination: { JournalEntryView(journal: $0) })
      .sheet(isPresented: $routingService.isPresentingCamera) {
        JournalCameraCaptureView(isPresenting: $routingService.isPresentingCamera)
      }
    }
  }
  
  private var colors = [Color.orange, .red, .blue, .green, .brown, .white]
  
  private var journals: some View {
    LazyVGrid(columns: Array.init(repeating: .init(.flexible(minimum: 100, maximum: 400)),
                                  count: 3),
              spacing: 20) {
      ForEach(Array(viewModel.journals.enumerated()), id: \.1.id) { (index, journal) in
        NavigationLink(value: journal) {
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
