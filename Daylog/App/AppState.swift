import Foundation
import Combine
import FirebaseAuth

/// Single source of truth for global auth state.
/// Subscribes to Firebase's auth state listener so `isLoggedIn` is always
/// accurate — no artificial delays or manual flag setting required.
@MainActor
final class AppState: ObservableObject {
    @Published private(set) var isLoggedIn: Bool = false

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Firebase fires this immediately with the cached user (or nil),
        // then again on every future sign-in / sign-out.
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                self?.isLoggedIn = user != nil
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
