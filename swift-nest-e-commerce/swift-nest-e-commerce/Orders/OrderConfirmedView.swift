// OrderConfirmedView.swift
// Displayed after successful order creation

import SwiftUI

struct OrderConfirmedView: View {
    let order: Order
    let onContinueShopping: () -> Void
    let onViewOrders: () -> Void

    @State private var showCheckmark = false
    @State private var showContent = false

    var body: some View {
        ZStack {
            // Background
            AnimatedGradientBackground()
                .opacity(0.9)

            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 60)

                    // Success Animation
                    SuccessCheckmark(show: $showCheckmark)
                        .padding(.bottom, 32)

                    // Order Confirmed Header
                    VStack(spacing: 12) {
                        Text("Order Confirmed!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text("Thank you for your purchase")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .padding(.bottom, 32)

                    // Order Details Card
                    OrderDetailsCard(order: order)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)

                    // Order Items Preview
                    OrderItemsPreview(items: order.items)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)

                    // Action Buttons
                    VStack(spacing: 16) {
                        // View Orders Button
                        Button(action: onViewOrders) {
                            HStack {
                                Image(systemName: "list.bullet.rectangle")
                                    .font(.system(size: 18))
                                Text("View My Orders")
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

                        // Continue Shopping Button
                        Button(action: onContinueShopping) {
                            HStack {
                                Image(systemName: "bag")
                                    .font(.system(size: 18))
                                Text("Continue Shopping")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.white)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showCheckmark = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Success Checkmark Animation

struct SuccessCheckmark: View {
    @Binding var show: Bool

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                .frame(width: 120, height: 120)

            // Animated ring
            Circle()
                .trim(from: 0, to: show ? 1 : 0)
                .stroke(
                    LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))

            // Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.green)
                .scaleEffect(show ? 1 : 0)
        }
    }
}

// MARK: - Order Details Card

struct OrderDetailsCard: View {
    let order: Order

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order Details")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            VStack(spacing: 12) {
                OrderDetailRow(label: "Order ID", value: String(order.id.prefix(8)) + "...")
                OrderDetailRow(label: "Date", value: order.formattedDate)
                OrderDetailRow(label: "Status", value: order.status.capitalized, isStatus: true, statusColor: order.statusColor)
                OrderDetailRow(label: "Items", value: "\(order.totalItems)")

                Divider()
                    .background(Color.white.opacity(0.2))

                HStack {
                    Text("Total")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(order.formattedTotal)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }
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

struct OrderDetailRow: View {
    let label: String
    let value: String
    var isStatus: Bool = false
    var statusColor: String = "gray"

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            if isStatus {
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusBackgroundColor)
                    .clipShape(Capsule())
            } else {
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }

    var statusBackgroundColor: Color {
        switch statusColor {
        case "orange": return .orange.opacity(0.3)
        case "blue": return .blue.opacity(0.3)
        case "purple": return .purple.opacity(0.3)
        case "green": return .green.opacity(0.3)
        case "red": return .red.opacity(0.3)
        default: return .gray.opacity(0.3)
        }
    }
}

// MARK: - Order Items Preview

struct OrderItemsPreview: View {
    let items: [OrderItem]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order Items")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            ForEach(items) { item in
                HStack(spacing: 12) {
                    // Item icon placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.1))
                        Image(systemName: "bag.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(width: 50, height: 50)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.productName)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text("Qty: \(item.quantity) x \(item.formattedPrice)")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    Text(item.formattedTotalPrice)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                )
            }
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
