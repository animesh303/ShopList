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
        HStack {
            Button(action: {
                item.isCompleted.toggle()
            }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .gray : .primary)
                
                HStack(spacing: 8) {
                    Text("\(formattedQuantity) \(item.unit ?? "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let price = item.estimatedPrice {
                        Text(price, format: .currency(code: settingsManager.currency.rawValue))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(item.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(item.category.color.opacity(0.2))
                        .foregroundColor(item.category.color)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            if let notes = item.notes, !notes.isEmpty {
                Image(systemName: "note.text")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    let item = Item(name: "Test Item", quantity: 2.0, category: .groceries, estimatedPrice: 10.99, unit: "kg")
    
    ItemRow(item: item)
        .modelContainer(container)
} 