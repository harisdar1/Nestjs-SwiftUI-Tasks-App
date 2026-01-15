//
//  swift_nest_e_commerceApp.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 11/01/2026.
//

import SwiftUI

@main
struct YourApp: App {
    @StateObject private var authManager = AuthManager.shared
      @StateObject private var cartManager = CartManager.shared
      
      var body: some Scene {
          WindowGroup {
              Group {
                  if authManager.isAuthenticated {
                      HomeView()
                          .environmentObject(authManager)
                          .environmentObject(cartManager)
                          .transition(.opacity)
                } else {
                    LoginView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
            .environmentObject(authManager)
        }
    }
}
