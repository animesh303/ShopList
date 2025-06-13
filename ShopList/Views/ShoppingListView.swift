import SwiftUI

struct ShoppingListView: View {
    let list: ShoppingList
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var showingAddItemSheet = false
    @State private var showingShareSheet = false
    
    var body: some View {
        List {
            ForEach(list.itemsByCategory.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { category, items in
                Section(header: Text(category.rawValue)) {
                    ForEach(items) { item in
                        HStack {
                            Button(action: {
                                var updatedList = list
                                updatedList.toggleItemCompletion(item)
                                viewModel.updateList(updatedList)
                            }) {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isCompleted ? .green : .gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .strikethrough(item.isCompleted)
                                if let notes = item.notes {
                                    Text(notes)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(item.quantity)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        var updatedList = list
                        let itemsToDelete = indexSet.map { items[$0] }
                        itemsToDelete.forEach { updatedList.removeItem($0) }
                        viewModel.updateList(updatedList)
                    }
                }
            }
        }
        .navigationTitle(list.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddItemSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showingAddItemSheet) {
            AddItemView(list: list, viewModel: viewModel)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [list.name])
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 