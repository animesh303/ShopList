//
//  ShopListApp.swift
//  ShopList
//
//  Created by Animesh Naskar on 13/06/25.
//

import SwiftUI
import AppIntents

@main
struct ShopListApp: App {
    @StateObject private var viewModel = ShoppingListViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modifier(iOSVersionCheck())
                .environmentObject(viewModel)
        }
    }
}

struct iOSVersionCheck: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
        } else {
            Text("This app requires iOS 16.0 or later")
        }
    }
}

// MARK: - App Shortcuts
@available(iOS 16.0, *)
extension ShopListApp {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: AddItemIntent(),
                phrases: [
                    "Add \(\.$itemName) to \(\.$listName)",
                    "Add \(\.$itemName) to my \(\.$listName) list",
                    "Add \(\.$itemName) to shopping list \(\.$listName)"
                ],
                shortTitle: "Add Item",
                systemImageName: "cart.badge.plus"
            ),
            AppShortcut(
                intent: CreateListIntent(),
                phrases: [
                    "Create shopping list \(\.$listName)",
                    "Make a new list called \(\.$listName)",
                    "Create a new shopping list named \(\.$listName)"
                ],
                shortTitle: "Create List",
                systemImageName: "list.bullet.clipboard"
            )
        ]
    }
}
