//
//  ContentView.swift
//  Finalproject
//
//  Created by Victoria Guzman on 11/27/24. [Categorization on importance for to-do's]
//  Edited by Zeid Zawaideh on 12/3/2024. [Added the add, edit, and delete operations for to-do app]

import SwiftUI

struct ContentView: View {
    @State private var items: [ToDoItem] = [
        ToDoItem(name: "Item A", importance: .high),
        ToDoItem(name: "Item B", importance: .medium),
        ToDoItem(name: "Item C", importance: .low)
    ]
    @State private var showAddItemView = false
    @State private var selectedItem: ToDoItem?
    @State private var showEditItemView = false

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
                            selectedItem = item
                            showEditItemView = true
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
                    addItem(newItem)
                }
            }
            .sheet(isPresented: $showEditItemView) {
                if let itemToEdit = selectedItem {
                    EditItemView(item: itemToEdit) { updatedItem in
                        updateItem(updatedItem)
                    }
                }
            }
        }
    }

    // MARK: - Add Item
    private func addItem(_ newItem: ToDoItem) {
        items.append(newItem)
    }

    // MARK: - Edit Item
    private func updateItem(_ updatedItem: ToDoItem) {
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
        }
    }

    // MARK: - Delete Item
    private func deleteItem(_ item: ToDoItem) {
        items.removeAll { $0.id == item.id }
    }
}

// MARK: - To-Do Item Model
struct ToDoItem: Identifiable {
    let id = UUID()
    var name: String
    var importance: Importance
}

// MARK: - Importance Enum
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

// MARK: - Add Item View
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

// MARK: - Edit Item View
struct EditItemView: View {
    @Environment(\.dismiss) var dismiss
    @State private var item: ToDoItem
    var onSave: (ToDoItem) -> Void

    init(item: ToDoItem, onSave: @escaping (ToDoItem) -> Void) {
        _item = State(initialValue: item)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $item.name)
                Picker("Importance", selection: $item.importance) {
                    ForEach(Importance.allCases, id: \.self) { importance in
                        Text(importance.rawValue.capitalized)
                    }
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(item)
                        dismiss()
                    }
                    .disabled(item.name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

