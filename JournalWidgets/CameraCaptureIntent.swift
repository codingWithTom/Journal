//
//  AppIntent.swift
//  JournalWidgets
//
//  Created by Tomas Trujillo on 2024-08-12.
//

import WidgetKit
import AppIntents

struct CameraCaptureIntent: AppIntent {
  static var title: LocalizedStringResource { "Photos for New Journal Entry" }
  static var description: IntentDescription { "Take pictures with the camera and create a new journal entry" }
  
  static var openAppWhenRun: Bool = true
  
  @Dependency
  private var routingService: RoutingServiceAdapter
  
  func perform() async throws -> some IntentResult {
    await routingService.changeCameraPresentation(true)
    return .result()
  }
}
