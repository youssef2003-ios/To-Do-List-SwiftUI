import Foundation
import Supabase

class SupabaseService {
    let supabase = SupabaseClient(supabaseURL: URL(string: "https://ahngbwkdqxepwdandubo.supabase.co")!,
                                  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFobmdid2tkcXhlcHdkYW5kdWJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTAwMzksImV4cCI6MjA1OTY4NjAzOX0.i0muAbg3dnuIhn_WdgidDwV7VPhwteiCtKrUK5apGyk")
    
    static let shared = SupabaseService()
    
    func postTodoItem(_ todo: ToDoModel) async throws -> ToDoModel {
        let item: ToDoModel = try await supabase
            .from("todos")
            .insert(todo, returning: .representation)
            .single()
            .execute()
            .value
        return item
    }
    
    func fetchTodos(forUser userId: UUID) async throws -> [ToDoModel] {
        return try await supabase
            .from("todos")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
    }
    
    func updateTodoItems(_ todo: ToDoModel) async throws {
        try await supabase
            .from("todos")
            .update(todo)
            .eq("id", value: todo.id)
            .select()
            .single()
            .execute()
            .value
    }
    
    func deleteTodoItems(id: Int) async throws {
        try await supabase
          .from("todos")
          .delete()
          .eq("id", value: id)
          .execute()
    }
}


