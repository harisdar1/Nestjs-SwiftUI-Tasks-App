//
//  CartViewModel.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 14/01/2026.
//


// CartViewModel.swift
import Foundation
import SwiftUI
internal import Combine

@MainActor
class CartViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var cartItems: [CartItem] = []
    @Published var totalItems = 0
    @Published var totalPrice: Double = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    @Published var showingCheckout = false
    
    init() {}
    private let apiService = APIService.shared
    private let badgeManager = CartBadgeManager.shared


    // Load cart data
    func loadCart() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let cartResponse = try await apiService.getMyCart()
            self.cartItems = cartResponse.items
            self.totalItems = cartResponse.totalItems
            self.totalPrice = cartResponse.totalPrice
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
    
    // Add product to cart
    func addToCart(product: Product, quantity: Int = 1) async {
        do {
            let cartResponse = try await apiService.addToCart(
                productId: product.id,
                quantity: quantity
            )
            updateCart(with: cartResponse)
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
    
    // Remove product from cart
    func removeFromCart(productId: String) async {
        do {
            let cartResponse = try await apiService.removeFromCart(productId: productId)
            updateCart(with: cartResponse)
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
    
    // Update quantity
    func updateQuantity(for productId: String, newQuantity: Int) async {
        if newQuantity <= 0 {
            await removeFromCart(productId: productId)
            return
        }
        
        do {
            let cartResponse = try await apiService.addToCart(
                productId: productId,
                quantity: newQuantity
            )
            updateCart(with: cartResponse)
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
    
    // Clear entire cart
    func clearCart() async {
           do {
               let success = try await apiService.clearCart()
               if success {
                   cartItems.removeAll()
                   totalItems = 0
                   totalPrice = 0
                   badgeManager.updateCount(0) // Update badge
               }
           } catch {
               errorMessage = error.localizedDescription
               showErrorAlert = true
           }
       }
    
    // Helper to update cart state
    private func updateCart(with response: CartResponse) {
          self.cartItems = response.items
          self.totalItems = response.totalItems
          self.totalPrice = response.totalPrice
          
          // Update badge
          badgeManager.updateCount(response.totalItems)
      }
    
    // Calculate item subtotal
    func itemSubtotal(for item: CartItem) -> String {
        return item.formattedTotalPrice
    }
    
    // Formatted total price
    var formattedTotalPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: totalPrice)) ?? "$0.00"
    }
}
