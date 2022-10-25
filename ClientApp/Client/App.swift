//
//  App.swift
//  Client
//
//  Created by Vladimir Petrov on 04/04/2022.
//

import SwiftUI

@main
struct clientApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationView {
        SwiftUIView()
      }
      .navigationViewStyle(StackNavigationViewStyle())
    }
  }
}
