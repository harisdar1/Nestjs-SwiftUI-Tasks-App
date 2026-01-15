//
//  HomeViewModel.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 13/01/2026.
//


// HomeViewModel.swift
import Foundation
import SwiftUI
internal import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var featuredProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    @Published var searchText = ""
    
    private let apiService = APIService.shared
    
    func loadHomeData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let categoriesTask = apiService.getCategories()
            async let productsTask = apiService.getProducts()
            
            let (categories, products) = try await (categoriesTask, productsTask)
            
            self.categories = categories
            self.featuredProducts = Array(products.prefix(8)) // Show first 8 as featured
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return featuredProducts
        }
        return featuredProducts.filter { product in
            product.name.localizedCaseInsensitiveContains(searchText) ||
            product.description.localizedCaseInsensitiveContains(searchText)
        }
    }
}
