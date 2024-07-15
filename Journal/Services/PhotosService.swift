//
//  PhotosService.swift
//  Journal
//
//  Created by Tomas Trujillo on 2024-07-12.
//

import Foundation

protocol PhotosService {
  func initializeDirectory()
  func saveImageData(_: Data, withName: String) throws
  func getURL(forName: String) -> URL
}

final class PhotosServiceAdapter: PhotosService {
  static let shared = PhotosServiceAdapter()
  
  private var directoryURL: URL?
  
  private init() { }
  
  func initializeDirectory() {
    guard
      let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    else {
      return
    }
    let photosDirectory = URL(fileURLWithPath: "Journal Photos", isDirectory: true, relativeTo: directory)
    do {
      if !FileManager.default.fileExists(atPath: photosDirectory.path) {
        try FileManager.default.createDirectory(atPath: photosDirectory.path, withIntermediateDirectories: true)
      }
      self.directoryURL = photosDirectory
    } catch {
      print("Error creating directory \(error)")
    }
  }
  
  func saveImageData(_ data: Data, withName name: String) throws {
    guard let directoryURL else { fatalError("Directory doesn't exist") }
    let fileURL = URL(fileURLWithPath: name, relativeTo: directoryURL)
    do {
      try data.write(to: fileURL)
    } catch {
      print("Error saving image \(error)")
      throw error
    }
  }
  
  func getURL(forName name: String) -> URL {
    guard let directoryURL else { fatalError("Directory doesn't exist") }
    return URL(fileURLWithPath: name, relativeTo: directoryURL)
  }
}
