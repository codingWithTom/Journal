//
//  JournalWidgetsControl.swift
//  JournalWidgets
//
//  Created by Tomas Trujillo on 2024-08-12.
//

import AppIntents
import SwiftUI
import WidgetKit

struct JournalWidgetsControl: ControlWidget {
    static let kind: String = "com.CodingWithTom.Journal.JournalWidgets"

    var body: some ControlWidgetConfiguration {
      StaticControlConfiguration(kind: Self.kind) {
        ControlWidgetButton(action: CameraCaptureIntent()) {
          Label("Take photos for new journal entry", systemImage: "camera.on.rectangle")
        }
      }
    }
}
