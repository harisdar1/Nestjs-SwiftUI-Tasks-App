//
//  Categories&products.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 13/01/2026.
//

import Foundation

struct Category: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let image: String
    let createdAt: String
    let updatedAt: String
}

struct Product: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let price: String
    let stock: Int
    let imageUrl: String
    let category: Category
    let createdAt: String
    let updatedAt: String
    
    var formattedPrice: String {
        guard let priceValue = Double(price) else { return price }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: priceValue)) ?? price
    }
}
