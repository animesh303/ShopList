//
//  ShopListApp.swift
//  ShopList
//
//  Created by Animesh Naskar on 13/06/25.
//

import SwiftUI
import SwiftData

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
            ZStack {
                // Enhanced background gradient for the entire app
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.background,
                        DesignSystem.Colors.secondaryBackground.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ContentView()
                    .modifier(iOSVersionCheck())
                    .environmentObject(viewModel)
                    .environmentObject(SubscriptionManager.shared)
                    .preferredColorScheme(settingsManager.appearance.colorScheme)
                    .id(settingsManager.appearance)
                    .onAppear {
                        // Set up notification categories
                        notificationManager.setupNotificationCategories()
                        // Set up model context for notification handling
                        notificationManager.setModelContext(container.mainContext)
                        // Set up model context for subscription manager
                        SubscriptionManager.shared.setModelContext(container.mainContext)
                    }

            }
        }
        .modelContainer(container)
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


