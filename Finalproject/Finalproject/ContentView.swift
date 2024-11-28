//
//  ContentView.swift
//  Finalproject
//
//  Created by Victoria Guzman on 11/27/24.
//

import SwiftUI

struct ContentView: View {
    @State private var items: [ToDoItem] = [
        ToDoItem(name: "Item A", importance: .high),
        ToDoItem(name: "Item B", importance: .medium),
        ToDoItem(name: "Item C", importance: .low)
    ]
    @State private var showAddItemView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    HStack {
                        Circle()
                            .fill(item.importance.color)
                            .frame(width: 10, height: 10)
                        Text(item.name)
                            .foregroundColor(.primary)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            editItem(item)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)

                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("To-Do List")
            .toolbar {
                Button(action: {
                    showAddItemView = true
                }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showAddItemView) {
                AddItemView { newItem in
                    items.append(newItem)
                }
            }
        }
    }

    private func editItem(_ item: ToDoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            // Example of a basic edit
            items[index].name = "Updated: \(item.name)"
        }
    }

    private func deleteItem(_ item: ToDoItem) {
        items.removeAll { $0.id == item.id }
    }
}

struct ToDoItem: Identifiable {
    let id = UUID()
    var name: String
    var importance: Importance
}

enum Importance: String, CaseIterable {
    case low, medium, high

    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
}

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var selectedImportance: Importance = .medium
    var onAdd: (ToDoItem) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $name)
                Picker("Importance", selection: $selectedImportance) {
                    ForEach(Importance.allCases, id: \.self) { importance in
                        Text(importance.rawValue.capitalized)
                    }
                }
            }
            .navigationTitle("Add New Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAdd(ToDoItem(name: name, importance: selectedImportance))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
