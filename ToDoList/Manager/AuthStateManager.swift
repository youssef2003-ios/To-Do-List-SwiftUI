import Foundation

class AuthStateManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isChecking = true
    
    func checkAuthState() {
        isChecking = true
        
        Task {
            do {
                _ = try await AuthService.shared.getCurrentUserId()
                await MainActor.run {
                    isAuthenticated = true
                    isChecking = false
                }
            } catch {
                print("No existing session found: \(error.localizedDescription)")
                await MainActor.run {
                    isAuthenticated = false
                    isChecking = false
                }
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await AuthService.shared.signOut()
                await MainActor.run {
                    isAuthenticated = false
                }
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    }
}
