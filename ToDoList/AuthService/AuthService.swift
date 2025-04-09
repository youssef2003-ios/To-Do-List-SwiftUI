import SwiftUI
import Supabase

// Authentication Service to handle login/signup with Supabase
class AuthService {
    static let shared = AuthService()
    private let supabase = SupabaseService.shared.supabase
    
    // Sign up with email and password
    func signUp(email: String, password: String) async throws -> User {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password
        )
        return response.user
    }
    
    // Sign in with email and password
    func signIn(email: String, password: String) async throws -> User {
        let response = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        return response.user
    }
    
    // Sign out the current user
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    // Get the current session if any
    func getSession() async throws -> Session? {
        try await supabase.auth.session
    }
    
    // Get current user ID or throw an error if not authenticated
    func getCurrentUserId() async throws -> UUID {
        let session = try await getSession()
        
        guard let session = session else {
            throw AuthError.notAuthenticated
        }
        
        return session.user.id
    }
    
    enum AuthError: Error, LocalizedError {
        case notAuthenticated
        
        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "User is not authenticated"
            }
        }
    }
}
