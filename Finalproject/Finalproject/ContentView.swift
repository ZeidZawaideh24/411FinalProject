//
//  ContentView.swift
//  Finalproject
//
//  Created by Victoria Guzman on 11/27/24.
//

import SwiftUI

struct ContentView: View {
    @State private var items: [ToDoItem] = [
        ToDoItem(name: "Item A", importance: .high, dueDate: Date().addingTimeInterval(86400)), // Example with due date
        ToDoItem(name: "Item B", importance: .medium, dueDate: nil),
        ToDoItem(name: "Item C", importance: .low, dueDate: Date().addingTimeInterval(-86400)) // Overdue example
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

                        VStack(alignment: .leading) {
                            Text(item.name)
                                .foregroundColor(.primary)
                            
                            if let dueDate = item.dueDate {
                                DueDateView(dueDate: dueDate) // Reusable component for displaying due dates
                            }
                        }
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
            items[index].name = "Updated: \(item.name)"
            items[index].dueDate = Date().addingTimeInterval(86400) // Update due date example
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
    var dueDate: Date?
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

struct DueDateView: View {
    var dueDate: Date

    var body: some View {
        let formattedDate = DateFormatter.shortDateFormatter.string(from: dueDate)
        Text("Due: \(formattedDate)")
            .font(.subheadline)
            .foregroundColor(dueDate < Date() ? .red : .gray)
    }
}

extension DateFormatter {
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var selectedImportance: Importance = .medium
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()

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

                Toggle("Set Due Date", isOn: $hasDueDate)

                if hasDueDate {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
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
                        onAdd(ToDoItem(name: name, importance: selectedImportance, dueDate: hasDueDate ? dueDate : nil))
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
