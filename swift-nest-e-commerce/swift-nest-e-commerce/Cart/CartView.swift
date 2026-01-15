//
//  CartView.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 14/01/2026.
//


// CartView.swift
import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @State private var showingClearConfirmation = false
    @State private var showingSuccessMessage = false
    @State private var successMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AnimatedGradientBackground()
                    .opacity(0.9)
                
                if viewModel.isLoading && viewModel.cartItems.isEmpty {
                    LoadingOverlay()
                } else {
                    VStack(spacing: 0) {
                        // Header
                        CartHeaderSection(
                            totalItems: viewModel.totalItems,
                            onClearCart: {
                                showingClearConfirmation = true
                            }
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                        
                        if viewModel.cartItems.isEmpty {
                            EmptyCartView()
                                .padding(.horizontal, 16)
                        } else {
                            ScrollView {
                                VStack(spacing: 0) {
                                    // Cart Items
                                    ForEach(viewModel.cartItems) { item in
                                        CartItemRow(
                                            item: item,
                                            onUpdateQuantity: { newQuantity in
                                                Task {
                                                    await viewModel.updateQuantity(
                                                        for: item.productId,
                                                        newQuantity: newQuantity
                                                    )
                                                }
                                            },
                                            onRemove: {
                                                Task {
                                                    await viewModel.removeFromCart(
                                                        productId: item.productId
                                                    )
                                                }
                                            }
                                        )
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                    }
                                    
                                    // Order Summary
                                    OrderSummarySection(
                                        subtotal: viewModel.totalPrice,
                                        shipping: 5.99,
                                        tax: viewModel.totalPrice * 0.08
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.top, 20)
                                    
                                    // Checkout Button
                                    CheckoutButton(
                                        totalPrice: viewModel.formattedTotalPrice,
                                        isLoading: viewModel.isLoading
                                    ) {
                                        viewModel.showingCheckout = true
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 24)
                                    .padding(.bottom, 40)
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.loadCart()
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .confirmationDialog(
                "Clear Cart",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Items", role: .destructive) {
                    Task {
                        await viewModel.clearCart()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to remove all items from your cart?")
            }
            .alert("Success", isPresented: $showingSuccessMessage) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(successMessage)
            }
            .sheet(isPresented: $viewModel.showingCheckout) {
                CheckoutView()
            }
            .refreshable {
                await viewModel.loadCart()
            }
        }
    }
}

// MARK: - Subviews

struct CartHeaderSection: View {
    let totalItems: Int
    let onClearCart: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Cart")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(totalItems) \(totalItems == 1 ? "item" : "items")")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            if totalItems > 0 {
                Button(action: onClearCart) {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.15))
                        )
                }
            }
        }
    }
}

// CartView.swift - Update CartItemRow
struct CartItemRow: View {
    let item: CartItem
    let onUpdateQuantity: (Int) -> Void
    let onRemove: () -> Void
    @State private var quantity: Int
    
    init(item: CartItem, onUpdateQuantity: @escaping (Int) -> Void, onRemove: @escaping () -> Void) {
        self.item = item
        self.onUpdateQuantity = onUpdateQuantity
        self.onRemove = onRemove
        self._quantity = State(initialValue: item.quantity)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Product Image - We'll need to fetch product details separately
            // For now, use a placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.3))
            }
            .frame(width: 80, height: 80)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: 8) {
                // Product Name
                Text(item.productName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                // Price per item
                Text(item.formattedPrice + " each")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                // Quantity Controls
                QuantityStepper(value: $quantity, onUpdate: onUpdateQuantity)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 12) {
                // Remove Button
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 28, height: 28)
                }
                
                // Item Total
                Text(item.formattedTotalPrice)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .onChange(of: quantity) { oldValue, newValue in
            if oldValue != newValue {
                onUpdateQuantity(newValue)
            }
        }
    }
}
struct QuantityStepper: View {
    @Binding var value: Int
    let onUpdate: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Decrease button
            Button(action: {
                if value > 1 {
                    value -= 1
                    onUpdate(value)
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                    )
            }
            .disabled(value <= 1)
            .opacity(value <= 1 ? 0.5 : 1)
            
            // Quantity display
            Text("\(value)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(minWidth: 40)
            
            // Increase button
            Button(action: {
                value += 1
                onUpdate(value)
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                    )
            }
        }
    }
}

struct OrderSummarySection: View {
    let subtotal: Double
    let shipping: Double
    let tax: Double
    
    var total: Double {
        subtotal + shipping + tax
    }
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: total)) ?? "$0.00"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Order Summary")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.bottom, 4)
            
            // Subtotal
            OrderSummaryRow(
                title: "Subtotal",
                value: subtotal,
                showDivider: true
            )
            
            // Shipping
            OrderSummaryRow(
                title: "Shipping",
                value: shipping,
                showDivider: true
            )
            
            // Tax
            OrderSummaryRow(
                title: "Tax",
                value: tax,
                showDivider: true
            )
            
            // Total
            HStack {
                Text("Total")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(formattedTotal)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct OrderSummaryRow: View {
    let title: String
    let value: Double
    let showDivider: Bool
    
    var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(formattedValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            if showDivider {
                Divider()
                    .background(Color.white.opacity(0.2))
            }
        }
    }
}

struct CheckoutButton: View {
    let totalPrice: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Proceed to Checkout")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Text("Total: \(totalPrice)")
                        .font(.system(size: 14))
                        .opacity(0.9)
                }
                .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1)
    }
}

struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "cart")
                .font(.system(size: 70))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("Your cart is empty")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Add some amazing products to get started!")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            NavigationLink(destination: HomeView()) {
                Text("Browse Products")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.top, 100)
    }
}

// MARK: - Checkout View

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CheckoutViewModel()
    @State private var showOrderConfirmed = false
    @State private var createdOrder: Order?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AnimatedGradientBackground()
                    .opacity(0.9)

                if viewModel.isLoading {
                    // Loading state
                    VStack(spacing: 24) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))

                        Text("Processing your order...")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Checkout confirmation
                    VStack(spacing: 0) {
                        Spacer()

                        VStack(spacing: 32) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 100, height: 100)

                                Image(systemName: "creditcard")
                                    .font(.system(size: 45))
                                    .foregroundColor(.white)
                            }

                            // Text
                            VStack(spacing: 12) {
                                Text("Confirm Order")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)

                                Text("Ready to place your order? Tap the button below to confirm your purchase.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }

                        Spacer()

                        // Place Order Button
                        Button(action: {
                            Task {
                                await placeOrder()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 20))
                                Text("Place Order")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.white)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                        // Cancel Button
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Failed to place order")
            }
            .fullScreenCover(isPresented: $showOrderConfirmed) {
                if let order = createdOrder {
                    OrderConfirmedView(
                        order: order,
                        onContinueShopping: {
                            showOrderConfirmed = false
                            dismiss()
                        },
                        onViewOrders: {
                            showOrderConfirmed = false
                            dismiss()
                            // Navigate to orders - handled by parent
                        }
                    )
                }
            }
        }
    }

    private func placeOrder() async {
        let order = await viewModel.createOrder()
        if let order = order {
            createdOrder = order
            showOrderConfirmed = true
        }
    }
}

// MARK: - Checkout ViewModel

@MainActor
class CheckoutViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false

    private let apiService = APIService.shared
    private let cartManager = CartManager.shared

    func createOrder() async -> Order? {
        isLoading = true
        defer { isLoading = false }

        do {
            let order = try await apiService.createOrder()
            // Clear local cart state after successful order
            await cartManager.loadCart()
            return order
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            return nil
        }
    }
}
