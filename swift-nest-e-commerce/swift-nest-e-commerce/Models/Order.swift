// Order.swift
// Models for Order API responses

import Foundation

// Order item (same structure as CartItem in order)
struct OrderItem: Codable, Identifiable {
    let productId: String
    let productName: String
    let quantity: Int
    let price: String

    var id: String { productId }

    var priceValue: Double {
        Double(price) ?? 0
    }

    var totalPrice: Double {
        priceValue * Double(quantity)
    }

    var formattedPrice: String {
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

// Order response from API
struct Order: Codable, Identifiable {
    let id: String
    let items: [OrderItem]
    let total: String
    let status: String
    let createdAt: String

    var totalValue: Double {
        Double(total) ?? 0
    }

    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: totalValue)) ?? total
    }

    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }

        // Fallback: try without fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }

        return createdAt
    }

    var statusColor: String {
        switch status.lowercased() {
        case "pending":
            return "orange"
        case "processing":
            return "blue"
        case "shipped":
            return "purple"
        case "delivered":
            return "green"
        case "cancelled":
            return "red"
        default:
            return "gray"
        }
    }
}
