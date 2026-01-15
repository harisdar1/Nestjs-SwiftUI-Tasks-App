//
//  CartButton.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 14/01/2026.
//


// CartButton.swift
import SwiftUI

struct CartButton: View {
    @EnvironmentObject private var cartManager: CartManager
    
    var body: some View {
        NavigationLink(destination: CartView()) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "cart")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                    )
                
                if cartManager.totalItems > 0 {
                    Text("\(cartManager.totalItems)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(minWidth: 18, minHeight: 18)
                        .padding(.horizontal, 4)
                        .background(Capsule().fill(Color.red))
                        .offset(x: -2, y: 2)
                }
            }
        }
    }
}