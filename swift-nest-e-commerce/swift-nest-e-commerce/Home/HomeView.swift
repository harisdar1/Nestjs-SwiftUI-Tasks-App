//
//  HomeView.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 13/01/2026.
//

// HomeView.swift
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showProfile = false
    @State private var showCart = false
    @Namespace private var animation
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var cartManager: CartManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AnimatedGradientBackground()
                    .opacity(0.9)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        HomeHeaderSection().environmentObject(authManager)

                        
                        // Search Bar
                        SearchSection(searchText: $viewModel.searchText)
                        
                        // Categories
                        CategoriesSection(categories: viewModel.categories)
                        
                        // Featured Products
                        FeaturedProductsSection(
                            products: viewModel.filteredProducts,
                            isLoading: viewModel.isLoading
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
                .scrollIndicators(.hidden)
                
                // Loading Overlay
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.loadHomeData()

            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .refreshable {
                await viewModel.loadHomeData()


            }
        }
    }
}

// MARK: - Subviews
struct HomeHeaderSection: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var showLogoutConfirmation = false
    @State private var showOrders = false
    @StateObject private var badgeManager = CartBadgeManager.shared

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome!")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                Text("Find amazing products")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            HStack(spacing: 12) {
                // Orders Button
                Button(action: {
                    showOrders = true
                }) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.15))
                        )
                }

                // Cart Button
                CartButton()

                // Logout Button
                Button(action: {
                    showLogoutConfirmation = true
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.15))
                        )
                }
                .confirmationDialog(
                    "Are you sure you want to logout?",
                    isPresented: $showLogoutConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Logout", role: .destructive) {
                        authManager.logout()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("You will need to login again to access your account.")
                }
            }
        }
        .padding(.top, 60)
        .padding(.bottom, 24)
        .fullScreenCover(isPresented: $showOrders) {
            OrdersListView()
        }
    }
}

struct SearchSection: View {
    @Binding var searchText: String
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(isSearchFocused ? .white : .white.opacity(0.6))
                .font(.system(size: 18))
            
            TextField("Search products...", text: $searchText)
                .foregroundColor(.white)
                .focused($isSearchFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSearchFocused ? Color.white.opacity(0.8) : Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.bottom, 24)
    }
}

struct CategoriesSection: View {
    let categories: [Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Categories")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to all categories
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(categories) { category in
                        CategoryCard(category: category)
                    }
                }
            }
        }
        .padding(.bottom, 32)
    }
}

struct CategoryCard: View {
    let category: Category
    
    var body: some View {
        Button(action: {
            // Navigate to category products
        }) {
            VStack(spacing: 12) {
                // Category Image
                AsyncImage(url: URL(string: category.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                
                // Category Name
                Text(category.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 80)
            }
        }
    }
}

// HomeView.swift - Update FeaturedProductsSection
struct FeaturedProductsSection: View {
    let products: [Product]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Featured Products")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to all products
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            }
            
            if isLoading && products.isEmpty {
                LoadingGrid()
            } else if products.isEmpty {
                EmptyProductsView()
            } else {
                ProductsGrid(products: products)
            }
        }
    }
}

struct ProductsGrid: View {
    let products: [Product]
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(products) { product in
                ProductCard(product: product)
            }
        }
    }
}


// HomeView.swift - Update ProductCard

struct ProductCard: View {
    let product: Product
    @EnvironmentObject private var cartManager: CartManager
    @State private var isFavorite = false
    @State private var showingAddToCartSuccess = false
    
    private var quantityInCart: Int {
        cartManager.quantityForProduct(productId: product.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ... existing image and product details code ...
            
            // Add to Cart/Quantity Control Section
            if quantityInCart > 0 {
                // Show quantity controls if already in cart
                HStack {
                    Button(action: {
                        Task {
                            let newQuantity = quantityInCart - 1
                            await cartManager.updateQuantity(for: product.id, newQuantity: newQuantity)
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.red.opacity(0.8))
                    }
                    
                    Text("\(quantityInCart) in cart")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(minWidth: 80)
                    
                    Button(action: {
                        Task {
                            let newQuantity = quantityInCart + 1
                            await cartManager.updateQuantity(for: product.id, newQuantity: newQuantity)
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.green.opacity(0.8))
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            } else {
                // Show Add to Cart button if not in cart
                Button(action: {
                    Task {
                        await cartManager.addToCart(product: product)
                        showingAddToCartSuccess = true
                    }
                }) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 14))
                        Text("Add to Cart")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
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
        .alert("Added to Cart", isPresented: $showingAddToCartSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(product.name) has been added to your cart")
        }
    }
}
struct LoadingGrid: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(0..<4, id: \.self) { _ in
                ProductCardSkeleton()
            }
        }
    }
}

struct ProductCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .frame(height: 150)
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 12)
                    .frame(maxWidth: .infinity)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 16)
                    .frame(width: 80)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 10)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct EmptyProductsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bag.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No products found")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Try searching for something else")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Custom Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
