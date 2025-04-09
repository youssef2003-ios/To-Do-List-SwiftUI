import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var authStateManager: AuthStateManager
    @State var todos = [ToDoModel]()
    @State var showingAlet = false
    @State var value: String = ""
    @State private var isLoading = true
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "ThirdColor") ?? UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "ThirdColor") ?? UIColor.black]
        
        UINavigationBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    if todos.isEmpty && !isLoading {
                        VStack(spacing: 15) {
                            Image(systemName: "list.clipboard")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                                .padding(.top, 100)
                            
                            Text("No tasks yet")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            Text("Add a new task to get started")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    } else {
                        VStack {
                            ForEach(todos.indices, id: \.self) { idx in
                                Button {
                                    // Action
                                    withAnimation {
                                        todos[idx].isComplete.toggle()
                                        updateTodoItem(todos[idx])
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: todos[idx].isComplete ?  "checkmark.circle.fill" : "circle")
                                        
                                        Text(todos[idx].title)
                                            .font(.system(size: 20, weight: .semibold))
                                            .strikethrough(todos[idx].isComplete, color: Color(.main))
                                    }// HStack
                                    .foregroundColor(Color.main)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color("SecondColor", bundle: nil))
                                    )
                                    
                                }// Button
                                .contextMenu {
                                    Button {
                                        withAnimation {
                                            deleteTodoItem(todos[idx])
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "trash.fill")
                                            
                                            Text("Delete")
                                        }
                                    }
                                }
                            }// ForEach
                        }// VStack1
                    }
                }// ScrollView
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .scrollIndicators(.hidden)
                .background(Color(.background))
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("To Do List")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // action
                        showingAlet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.mint.opacity(0.7))
                            .font(.title2)
                    }
                }
            }
            .alert("Add Items", isPresented: $showingAlet) {
                VStack {
                    TextField("Enter Item:", text: $value)
                    
                    HStack {
                        Button(role: .cancel) {
                        } label: {
                            Text("Cancel")
                        }
                        
                        Button {
                            didAddItem()
                        } label: {
                            Text("Done")
                        }
                    }// HStack
                }// VStack
            }// Alert
            .onAppear {
                fetchTodoItems()
            }
        }
    }
    
    func fetchTodoItems() {
        isLoading = true
        
        Task {
            do {
                // Will throw an error if not authenticated
                let userId = try await AuthService.shared.getCurrentUserId()
                let fetchedTodos = try await SupabaseService.shared.fetchTodos(forUser: userId)
                
                await MainActor.run {
                    todos = fetchedTodos
                    isLoading = false
                }
            } catch {
                print("Auth check failed: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                    authStateManager.isAuthenticated = false
                }
            }
        }
    }
    
    func signOut() {
        authStateManager.signOut()
    }
    
    func didAddItem() {
        if !value.isEmpty && value.count > 2 {
            Task {
                do {
                    // Get the current user ID (will throw if not authenticated)
                    let userId = try await AuthService.shared.getCurrentUserId()
                    
                    let todo = ToDoModel(
                        id: nil, // Make sure ID is nil for new items
                        createdAt: .now,
                        title: value,
                        isComplete: false,
                        userId: userId
                    )
                    
                    let returnedItem = try await SupabaseService.shared.postTodoItem(todo)
                    
                    await MainActor.run {
                        todos.append(returnedItem)
                        showingAlet = false
                        value = ""
                    }
                } catch {
                    print("DEBUG: error with didAddItem \(error.localizedDescription)")
                    
                    // If authentication error, redirect to auth
                    if error is AuthService.AuthError {
                        await MainActor.run {
                            authStateManager.isAuthenticated = false
                        }
                    }
                }
            }
        }
    }
    
    func updateTodoItem(_ todo: ToDoModel) {
        Task {
            do {
                guard let id = todo.id else {
                    print("Cannot update todo without an ID")
                    return
                }
                
                // Create a copy with explicit ID to avoid NULL errors
                var updatedTodo = todo
                updatedTodo.id = id
                
                try await SupabaseService.shared.updateTodoItems(updatedTodo)
            } catch {
                print("DEBUG: error with updateTodoItem \(error.localizedDescription)")
                
                // If authentication error, redirect to auth
                if error.localizedDescription.contains("Auth") {
                    await MainActor.run {
                        authStateManager.isAuthenticated = false
                    }
                }
            }
        }
    }
    
    func deleteTodoItem(_ todo: ToDoModel) {
        Task {
            do {
                guard let id = todo.id else {
                    print("Cannot delete todo without an ID")
                    return
                }
                
                try await SupabaseService.shared.deleteTodoItems(id: id)
                
                await MainActor.run {
                    todos.removeAll { $0.id == id }
                }
            } catch {
                print("DEBUG: error with deleteTodoItem \(error.localizedDescription)")
                
                // If authentication error, redirect to auth
                if error.localizedDescription.contains("Auth") {
                    await MainActor.run {
                        authStateManager.isAuthenticated = false
                    }
                }
            }
        }
    }
}

#Preview {
    TodoListView()
}
