import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authStateManager: AuthStateManager
    
    var body: some View {
        ZStack {
            // Background color matching your app style
            Color(UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0))
                .ignoresSafeArea()
                
            if authStateManager.isChecking {
                ProgressView("Checking authentication...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .font(.headline)
            } else if authStateManager.isAuthenticated {
                TodoListView()
            } else {
                AuthView()
            }
        }
    }
}
#Preview {
    ContentView()
}
