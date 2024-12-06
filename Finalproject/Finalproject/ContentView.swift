//
//  ContentView.swift
//  Finalproject
//
//  Created by Victoria Guzman on 11/27/24. [Categorization on importance for to-do's]
//  Edited by Zeid Zawaideh on 12/3/2024. [Added the add, edit, and delete operations for to-do app]
//  Edited by Tyler Lui on 12/4/2024. [Added the checkmark button to cross off completed tasks]
//  Edited by Quan Yingmin on 12/4/2024. [Added due date feature with color-coded dates]
//  Edited by Timothy Hulse on 12/5/2024 [Added reordering functionality with EditMode to enable task rearrangement]


import SwiftUI

//MARK: - Main Content View
struct ContentView: View {
    @State private var items: [ToDoItem] = []
    @State private var showAddItemView = false
    @State private var selectedItem: ToDoItem?
    @State private var showEditItemView = false
    @State private var editMode: EditMode = .inactive // Track edit mode for reordering

    var body: some View {
        NavigationView {
            List {
                ForEach($items) { $item in
                    HStack {
                        Button(action: {
                            item.isChecked.toggle()
                            saveItems()
                        }) {
                            Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                                .foregroundColor(item.isChecked ? .green : .primary)
                        }
                        Circle()
                            .fill(item.importance.color)
                            .frame(width: 10, height: 10)
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .foregroundColor(item.isChecked ? .secondary : .primary)
                                .strikethrough(item.isChecked, color: .secondary)
                                .font(.headline)
                            if let dueDate = item.dueDate {
                                Text("Due: \(dueDate, style: .date)")
                                    .font(.subheadline)
                                    .foregroundColor(item.isOverdue ? .red : (item.isDueToday ? .orange : .secondary))
                            }
                        }
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
                .onMove(perform: moveItem) // Enable reordering functionality
            }
            .listStyle(.insetGrouped)
            .navigationTitle("To-Do List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        editMode = editMode == .active ? .inactive : .active
                    }) {
                        Text(editMode == .active ? "Done" : "Edit")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddItemView = true
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .environment(\.editMode, $editMode) // Pass edit mode binding
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
        .onAppear() {
            loadItems()
        }
    }
    
    // MARK: - Persistence
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "ToDoItems")
        }
    }
    
    private func loadItems() {
        if let savedData = UserDefaults.standard.data(forKey: "ToDoItems"),
           let decodedItems = try? JSONDecoder().decode([ToDoItem].self, from: savedData) {
            items = decodedItems
        }
    }
    
    
    // MARK: - Add Item
    private func addItem(_ newItem: ToDoItem) {
        items.append(newItem)
        saveItems()
    }
    
    // MARK: - Edit Item
    private func updateItem(_ updatedItem: ToDoItem) {
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
            saveItems()
        }
    }
    
    // MARK: - Delete Item
    private func deleteItem(_ item: ToDoItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    // MARK: - Move Item (Reorder)
    private func moveItem(fromOffsets source: IndexSet, toOffset destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        saveItems()
    }
}

// MARK: - To-Do Item Model
struct ToDoItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var importance: Importance
    var isChecked: Bool
    var dueDate: Date?
    var isOverdue: Bool {
        if let dueDate = dueDate {
            return !isChecked && dueDate < Calendar.current.startOfDay(for: Date())
        }
        return false
    }
    
    var isDueToday: Bool {
        if let dueDate = dueDate {
            let today = Calendar.current.startOfDay(for: Date())
            return !isChecked && Calendar.current.isDate(dueDate, inSameDayAs: today)
        }
        return false
    }
    
    init(id: UUID = UUID(), name: String, importance: Importance, isChecked: Bool, dueDate: Date? = nil) {
        self.id = id
        self.name = name
        self.importance = importance
        self.isChecked = isChecked
        self.dueDate = dueDate
    }
}

// MARK: - Importance Enum
enum Importance: String, CaseIterable, Codable {
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
    @State private var selectedDueDate: Date = Date()
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
                DatePicker("Due Date", selection: $selectedDueDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
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
                        onAdd(ToDoItem(name: name, importance: selectedImportance, isChecked: false, dueDate: selectedDueDate))
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
                DatePicker("Due Date", selection: Binding(
                    get: { item.dueDate ?? Date() },
                    set: { item.dueDate = $0 }
                ), displayedComponents: .date)
                    .datePickerStyle(.compact)
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
