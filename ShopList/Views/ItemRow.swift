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
        VStack(alignment: .leading, spacing: 12) {
            // Main row with completion, image, and name
            HStack(spacing: 16) {
                Button(action: toggleCompletion) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(item.isCompleted ? .green : .gray)
                        .scaleEffect(item.isCompleted ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: item.isCompleted)
                }
                .buttonStyle(.plain)
                
                // Enhanced Item Image
                if settingsManager.showItemImagesByDefault {
                    if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    } else {
                        Image(systemName: item.category.icon)
                            .font(.title)
                            .foregroundColor(item.category.color)
                            .frame(width: 64, height: 64)
                            .background(
                                LinearGradient(
                                    colors: [item.category.color.opacity(0.2), item.category.color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    Image(systemName: item.category.icon)
                        .font(.title)
                        .foregroundColor(item.category.color)
                        .frame(width: 64, height: 64)
                        .background(
                            LinearGradient(
                                colors: [item.category.color.opacity(0.2), item.category.color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .strikethrough(item.isCompleted)
                        
                        if let brand = item.brand, !brand.isEmpty {
                            Text("•")
                                .foregroundColor(.gray)
                            Text(brand)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Enhanced Category and Priority
                    HStack(spacing: 10) {
                        Text(item.category.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [item.category.color.opacity(0.2), item.category.color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(item.category.color)
                            .cornerRadius(10)
                        
                        if item.priority != .normal {
                            HStack(spacing: 4) {
                                Image(systemName: priorityIcon)
                                    .foregroundColor(priorityColor)
                                    .font(.caption)
                                Text(item.priority.displayName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(priorityColor)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(priorityColor.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Enhanced Details row
            HStack(spacing: 20) {
                if item.quantity > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "number.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let price = item.estimatedPrice, price > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text(price, format: .currency(code: settingsManager.currency.rawValue))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
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