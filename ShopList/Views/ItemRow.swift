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
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
    }
    
    // MARK: - Compact View
    private var compactView: some View {
        HStack(spacing: 16) {
            Button(action: toggleCompletion) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .green : .gray)
                    .scaleEffect(item.isCompleted ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: item.isCompleted)
            }
            .buttonStyle(.plain)
            
            // Enhanced Category Icon
            Image(systemName: item.category.icon)
                .font(.title3)
                .foregroundColor(item.category.color)
                .frame(width: 32, height: 32)
                .background(
                    LinearGradient(
                        colors: [item.category.color.opacity(0.2), item.category.color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Item Name and Brand with enhanced typography
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.body)
                        .fontWeight(.medium)
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
                
                // Quantity and Price with enhanced styling
                HStack(spacing: 8) {
                    if item.quantity > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "number.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let price = item.estimatedPrice, price > 0 {
                        if item.quantity > 0 {
                            Text("•")
                                .foregroundColor(.gray)
                                .font(.caption2)
                        }
                        HStack(spacing: 2) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                            Text(price, format: .currency(code: settingsManager.currency.rawValue))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Enhanced Priority indicator
            if item.priority != .normal {
                Image(systemName: priorityIcon)
                    .foregroundColor(priorityColor)
                    .font(.caption)
                    .padding(6)
                    .background(priorityColor.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }
    
    // MARK: - Detailed View
    private var detailedView: some View {
        HStack(alignment: .top, spacing: 12) {
            // Completion button
            Button(action: toggleCompletion) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .green : .gray)
                    .scaleEffect(item.isCompleted ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: item.isCompleted)
            }
            .buttonStyle(.plain)
            
            // Item image/icon
            if settingsManager.showItemImagesByDefault {
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: item.category.icon)
                        .font(.title3)
                        .foregroundColor(item.category.color)
                        .frame(width: 50, height: 50)
                        .background(item.category.color.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                Image(systemName: item.category.icon)
                    .font(.title3)
                    .foregroundColor(item.category.color)
                    .frame(width: 50, height: 50)
                    .background(item.category.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Content area
            VStack(alignment: .leading, spacing: 6) {
                // Item name and brand
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .strikethrough(item.isCompleted)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let brand = item.brand, !brand.isEmpty {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // Category and priority badges in a single row
                HStack(spacing: 6) {
                    // Category badge with icon
                    HStack(spacing: 3) {
                        Image(systemName: item.category.icon)
                            .font(.caption2)
                            .foregroundColor(item.category.color)
                        Text(item.category.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(item.category.color)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(item.category.color.opacity(0.15))
                    .cornerRadius(4)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    
                    // Priority badge
                    if item.priority != .normal {
                        HStack(spacing: 2) {
                            Image(systemName: priorityIcon)
                                .font(.caption2)
                                .foregroundColor(priorityColor)
                            Text(item.priority.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(priorityColor)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(priorityColor.opacity(0.15))
                        .cornerRadius(4)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                    
                    Spacer()
                }
                
                // Quantity and price info
                HStack(spacing: 12) {
                    if item.quantity > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "number.circle.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let price = item.estimatedPrice, price > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(price, format: .currency(code: settingsManager.currency.rawValue))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
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