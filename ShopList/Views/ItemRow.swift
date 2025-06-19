import SwiftUI
import SwiftData

struct ItemRow: View {
    @Bindable var item: Item
    @StateObject private var settingsManager = UserSettingsManager.shared
    
    private var formattedQuantity: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSDecimalNumber(decimal: item.quantity)) ?? "0"
    }
    
    var body: some View {
        Group {
            if settingsManager.defaultItemViewStyle == .compact {
                compactView
            } else {
                detailedView
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    // MARK: - Compact View
    private var compactView: some View {
        HStack(spacing: 12) {
            Button(action: toggleCompletion) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Category Icon (smaller)
            Image(systemName: item.category.icon)
                .font(.title3)
                .foregroundColor(item.category.color)
                .frame(width: 30, height: 30)
                .background(item.category.color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Item Name and Brand
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(item.name)
                        .font(.body)
                        .strikethrough(item.isCompleted)
                        .lineLimit(1)
                    
                    if let brand = item.brand, !brand.isEmpty {
                        Text("•")
                            .foregroundColor(.gray)
                            .font(.caption)
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                // Quantity and Price (condensed)
                HStack(spacing: 6) {
                    if item.quantity > 0 {
                        Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    if let price = item.estimatedPrice, price > 0 {
                        if item.quantity > 0 {
                            Text("•")
                                .foregroundColor(.gray)
                                .font(.caption2)
                        }
                        Text(price, format: .currency(code: settingsManager.currency.rawValue))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // Priority indicator (smaller)
            if item.priority != .normal {
                Image(systemName: priorityIcon)
                    .foregroundColor(priorityColor)
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Detailed View
    private var detailedView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main row with completion, image, and name
            HStack(spacing: 12) {
                Button(action: toggleCompletion) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(item.isCompleted ? .green : .gray)
                }
                .buttonStyle(.plain)
                
                // Item Image (larger)
                if settingsManager.showItemImagesByDefault {
                    if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        Image(systemName: item.category.icon)
                            .font(.title)
                            .foregroundColor(item.category.color)
                            .frame(width: 60, height: 60)
                            .background(item.category.color.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                } else {
                    Image(systemName: item.category.icon)
                        .font(.title)
                        .foregroundColor(item.category.color)
                        .frame(width: 60, height: 60)
                        .background(item.category.color.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                            .strikethrough(item.isCompleted)
                        
                        if let brand = item.brand, !brand.isEmpty {
                            Text("•")
                                .foregroundColor(.gray)
                            Text(brand)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Category and Priority
                    HStack(spacing: 8) {
                        Text(item.category.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(item.category.color.opacity(0.2))
                            .foregroundColor(item.category.color)
                            .cornerRadius(8)
                        
                        if item.priority != .normal {
                            HStack(spacing: 4) {
                                Image(systemName: priorityIcon)
                                    .foregroundColor(priorityColor)
                                    .font(.caption)
                                Text(item.priority.displayName)
                                    .font(.caption)
                                    .foregroundColor(priorityColor)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            // Details row
            HStack(spacing: 16) {
                if item.quantity > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "number.circle")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let price = item.estimatedPrice, price > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text(price, format: .currency(code: settingsManager.currency.rawValue))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Notes (if enabled and available)
            if settingsManager.showItemNotesByDefault, let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
    }
    
    private var priorityIcon: String {
        switch item.priority {
        case .low:
            return "arrow.down.circle"
        case .normal:
            return "circle"
        case .high:
            return "exclamationmark.circle"
        }
    }
    
    private var priorityColor: Color {
        switch item.priority {
        case .low:
            return .gray
        case .normal:
            return .blue
        case .high:
            return .red
        }
    }
    
    private func toggleCompletion() {
        item.isCompleted.toggle()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    let item = Item(name: "Test Item", quantity: 2.0, category: .groceries, estimatedPrice: 10.99, unit: "kg")
    item.brand = "Test Brand"
    item.notes = "This is a sample note for testing the detailed view"
    item.priority = .high
    
    return VStack(spacing: 20) {
        Text("Compact View")
            .font(.headline)
            .padding(.top)
        
        ItemRow(item: item)
            .modelContainer(container)
        
        Text("Detailed View")
            .font(.headline)
        
        ItemRow(item: item)
            .modelContainer(container)
    }
    .padding()
} 