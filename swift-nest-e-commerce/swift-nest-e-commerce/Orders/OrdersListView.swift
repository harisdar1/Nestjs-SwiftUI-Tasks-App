// OrdersListView.swift
// Displays list of user's orders

import SwiftUI

struct OrdersListView: View {
    @StateObject private var viewModel = OrdersViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AnimatedGradientBackground()
                    .opacity(0.9)

                VStack(spacing: 0) {
                    // Header
                    OrdersHeaderSection(onBack: { dismiss() })
                        .padding(.horizontal, 16)
                        .padding(.top, 60)
                        .padding(.bottom, 20)

                    if viewModel.isLoading && viewModel.orders.isEmpty {
                        LoadingOverlay()
                    } else if viewModel.orders.isEmpty {
                        EmptyOrdersView()
                            .padding(.horizontal, 16)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.orders) { order in
                                    OrderCard(order: order)
                                        .padding(.horizontal, 16)
                                }
                            }
                            .padding(.bottom, 40)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.loadOrders()
            }
            .refreshable {
                await viewModel.loadOrders()
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
}

// MARK: - Orders Header

struct OrdersHeaderSection: View {
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                    )
            }

            Spacer()

            VStack(spacing: 2) {
                Text("My Orders")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()

            // Placeholder for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
    }
}

// MARK: - Order Card

struct OrderCard: View {
    let order: Order
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Order Summary (always visible)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 16) {
                    // Order icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(statusBackgroundColor)
                        Image(systemName: statusIcon)
                            .font(.system(size: 20))
                            .foregroundColor(statusForegroundColor)
                    }
                    .frame(width: 50, height: 50)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order #\(String(order.id.prefix(8)))")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Text(order.formattedDate)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(order.formattedTotal)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        StatusBadge(status: order.status, color: order.statusColor)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(16)
            }

            // Expanded Items List
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal, 16)

                    VStack(spacing: 12) {
                        ForEach(order.items) { item in
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                    Image(systemName: "bag.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .frame(width: 40, height: 40)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.productName)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)

                                    Text("Qty: \(item.quantity) x \(item.formattedPrice)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()

                                Text(item.formattedTotalPrice)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(16)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
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

    var statusIcon: String {
        switch order.status.lowercased() {
        case "pending": return "clock"
        case "processing": return "gearshape"
        case "shipped": return "shippingbox"
        case "delivered": return "checkmark.circle"
        case "cancelled": return "xmark.circle"
        default: return "questionmark.circle"
        }
    }

    var statusBackgroundColor: Color {
        switch order.statusColor {
        case "orange": return .orange.opacity(0.2)
        case "blue": return .blue.opacity(0.2)
        case "purple": return .purple.opacity(0.2)
        case "green": return .green.opacity(0.2)
        case "red": return .red.opacity(0.2)
        default: return .gray.opacity(0.2)
        }
    }

    var statusForegroundColor: Color {
        switch order.statusColor {
        case "orange": return .orange
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "red": return .red
        default: return .gray
        }
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: String
    let color: String

    var body: some View {
        Text(status.capitalized)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    var backgroundColor: Color {
        switch color {
        case "orange": return .orange.opacity(0.2)
        case "blue": return .blue.opacity(0.2)
        case "purple": return .purple.opacity(0.2)
        case "green": return .green.opacity(0.2)
        case "red": return .red.opacity(0.2)
        default: return .gray.opacity(0.2)
        }
    }

    var foregroundColor: Color {
        switch color {
        case "orange": return .orange
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "red": return .red
        default: return .gray
        }
    }
}

// MARK: - Empty Orders View

struct EmptyOrdersView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bag")
                .font(.system(size: 70))
                .foregroundColor(.white.opacity(0.3))

            VStack(spacing: 8) {
                Text("No orders yet")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text("Your order history will appear here once you make a purchase.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            NavigationLink(destination: HomeView()) {
                Text("Start Shopping")
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

// MARK: - Orders ViewModel

@MainActor
class OrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false

    private let apiService = APIService.shared

    func loadOrders() async {
        isLoading = true
        defer { isLoading = false }

        do {
            orders = try await apiService.getMyOrders()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}
