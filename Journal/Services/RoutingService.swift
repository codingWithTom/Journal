//
//  RoutingService.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-08-12.
//

import Foundation


protocol RoutingService {
  @MainActor
  var isPresentingCamera: Bool { get set }
  
  func getCameraPresentation() async -> Bool
  func changeCameraPresentation(_: Bool) async
}

@MainActor
@Observable class RoutingServiceAdapter: RoutingService {
  static let shared =  RoutingServiceAdapter()
  
  var isPresentingCamera: Bool = false
  
  private init() { }
  
  func getCameraPresentation() async -> Bool {
    isPresentingCamera
  }
  
  func changeCameraPresentation(_ isPresenting: Bool) async {
    self.isPresentingCamera = isPresenting
  }
}
