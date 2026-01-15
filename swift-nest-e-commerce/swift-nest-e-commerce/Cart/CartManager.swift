// CartManager.swift

internal import Combine
import Foundation


@MainActor
class CartManager: ObservableObject {
    static let shared = CartManager()

    @Published var items: [CartItem] = []
    @Published var totalItems: Int = 0
    @Published var totalPrice: Double = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var cartId: String?

    private let apiService = APIService.shared
    private let badgeManager = CartBadgeManager.shared

    private init() {
        // Optionally load cart on initialization
    }
    
    // Load cart data
    func loadCart() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let cartResponse = try await apiService.getMyCart()
            updateCart(with: cartResponse)
        } catch {
            errorMessage = error.localizedDescription
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
        }
    }
    
    // Remove product from cart
    func removeFromCart(productId: String) async {
        do {
            let cartResponse = try await apiService.removeFromCart(productId: productId)
            updateCart(with: cartResponse)
        } catch {
            errorMessage = error.localizedDescription
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
        }
    }
    
    // Clear entire cart
    func clearCart() async {
        do {
            let success = try await apiService.clearCart()
            if success {
                items.removeAll()
                totalItems = 0
                totalPrice = 0
                cartId = nil
                badgeManager.updateCount(0)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Helper to update cart state
    private func updateCart(with response: CartResponse) {
        self.items = response.items
        self.totalItems = response.totalItems
        self.totalPrice = response.totalPrice
        self.cartId = response.id
        badgeManager.updateCount(response.totalItems)
    }
    
    // Check if product is in cart
    func isProductInCart(productId: String) -> Bool {
        items.contains { $0.productId == productId }
    }
    
    // Get quantity for a product
    func quantityForProduct(productId: String) -> Int {
        items.first { $0.productId == productId }?.quantity ?? 0
    }
    
    // Formatted total price
    var formattedTotalPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: totalPrice)) ?? "$0.00"
    }
    
    // Get cart item by product ID
    func getCartItem(for productId: String) -> CartItem? {
        items.first { $0.productId == productId }
    }
}
