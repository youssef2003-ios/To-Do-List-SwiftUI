import SwiftUI

@main
struct ToDoListApp: App {
    @StateObject private var authStateManager = AuthStateManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authStateManager)
                .onAppear {
                    authStateManager.checkAuthState()
                }
        }
    }
}
