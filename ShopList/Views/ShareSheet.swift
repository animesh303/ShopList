import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let onDismiss: () -> Void
    
    init(activityItems: [Any], onDismiss: @escaping () -> Void = {}) {
        self.activityItems = activityItems
        self.onDismiss = onDismiss
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        
        // Set completion handler to dismiss the sheet
        controller.completionWithItemsHandler = { _, _, _, _ in
            onDismiss()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
} 