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
        HStack(spacing: 12) {
            Button(action: toggleCompletion) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Item Image
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: item.category.icon)
                    .font(.title2)
                    .foregroundColor(item.category.color)
                    .frame(width: 50, height: 50)
                    .background(item.category.color.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
                
                HStack(spacing: 8) {
                    if item.quantity > 0 {
                        Text(String(format: "%.1f %@", NSDecimalNumber(decimal: item.quantity).doubleValue, item.unit ?? ""))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if let price = item.estimatedPrice, price > 0 {
                        Text("•")
                            .foregroundColor(.gray)
                        Text(price, format: .currency(code: settingsManager.currency.rawValue))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text("•")
                        .foregroundColor(.gray)
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if item.priority != .normal {
                Image(systemName: priorityIcon)
                    .foregroundColor(priorityColor)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
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
    
    ItemRow(item: item)
        .modelContainer(container)
} 