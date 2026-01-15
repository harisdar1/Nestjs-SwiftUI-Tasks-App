// CartModels.swift
import Foundation
struct AddToCartRequest: Encodable {
    let productId: String
    let quantity: Int
}

// Updated CartItem to match API response
struct CartItem: Codable, Identifiable {
    let productId: String
    let productName: String
    let quantity: Int
    let price: String
    
    // Computed properties
    var id: String { productId }
    
    var totalPrice: Double {
        guard let priceValue = Double(price) else { return 0 }
        return priceValue * Double(quantity)
    }
    
    var formattedPrice: String {
        guard let priceValue = Double(price) else { return price }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: priceValue)) ?? price
    }
    
    var formattedTotalPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: totalPrice)) ?? "$0.00"
    }
}

// Updated CartResponse to match API response
struct CartResponse: Codable {
    let id: String
    let items: [CartItem]
    let total: String
    let createdAt: String
    let updatedAt: String
    
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Double {
        guard let totalValue = Double(total) else { return 0 }
        return totalValue
    }
    
    var formattedTotalPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        guard let totalValue = Double(total) else { return total }
        return formatter.string(from: NSNumber(value: totalValue)) ?? total
    }
}
