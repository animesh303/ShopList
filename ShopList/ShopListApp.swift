//
//  ShopListApp.swift
//  ShopList
//
//  Created by Animesh Naskar on 13/06/25.
//

import SwiftUI
import AppIntents
import SwiftData
import WidgetKit

@main
struct ShopListApp: App {
    let container: ModelContainer
    @StateObject private var viewModel: ShoppingListViewModel
    @StateObject private var settingsManager = UserSettingsManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(for: ShoppingList.self, Item.self, ItemHistory.self, configurations: config)
            let viewModel = ShoppingListViewModel(modelContext: container.mainContext)
            _viewModel = StateObject(wrappedValue: viewModel)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modifier(iOSVersionCheck())
                .environmentObject(viewModel)
                .preferredColorScheme(settingsManager.appearance.colorScheme)
                .onAppear {
                    // Set up notification categories
                    notificationManager.setupNotificationCategories()
                    // Set up model context for notification handling
                    notificationManager.setModelContext(container.mainContext)
                }
                .onChange(of: container.mainContext.hasChanges) { _, hasChanges in
                    if hasChanges {
                        updateWidgetData()
                    }
                }
        }
        .modelContainer(container)
    }
    
    private func updateWidgetData() {
        Task {
            let context = container.mainContext
            let descriptor = FetchDescriptor<ShoppingList>()
            
            do {
                let lists = try context.fetch(descriptor)
                let widgetLists = lists.map { WidgetShoppingList(from: $0) }
                
                if let encodedData = try? JSONEncoder().encode(widgetLists) {
                    UserDefaults.standard.set(encodedData, forKey: "shoppingLists")
                    WidgetCenter.shared.reloadAllTimelines()
                }
            } catch {
                print("Failed to update widget data: \(error)")
            }
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
