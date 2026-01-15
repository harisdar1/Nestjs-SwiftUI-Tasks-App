//
//  CartBadgeManager.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 14/01/2026.
//


// CartBadgeManager.swift
import Foundation
internal import Combine

class CartBadgeManager: ObservableObject {
    static let shared = CartBadgeManager()
    
    @Published var itemCount: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // You can observe cart changes here if needed
    }
    
    func updateCount(_ count: Int) {
        itemCount = count
    }
}
