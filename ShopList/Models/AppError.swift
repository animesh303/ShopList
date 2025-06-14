import Foundation
import SwiftUI

enum AppError: LocalizedError {
    // Data Errors
    case dataEncodingError(String)
    case dataDecodingError(String)
    case dataNotFound(String)
    case dataSaveError(String)
    
    // Validation Errors
    case invalidInput(String)
    case invalidQuantity
    case invalidListName
    case listAlreadyExists
    case listNotFound
    
    // User Interface Errors
    case uiError(String)
    
    // Network Errors (if you add networking in future)
    case networkError(String)
    case serverError(String)
    
    // Permission Errors
    case permissionDenied(String)
    
    var errorDescription: String? {
        switch self {
        case .dataEncodingError(let message):
            return "Failed to encode data: \(message)"
        case .dataDecodingError(let message):
            return "Failed to decode data: \(message)"
        case .dataNotFound(let message):
            return "Data not found: \(message)"
        case .dataSaveError(let message):
            return "Failed to save data: \(message)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .invalidQuantity:
            return "Quantity must be greater than 0"
        case .invalidListName:
            return "List name cannot be empty"
        case .listAlreadyExists:
            return "A list with this name already exists"
        case .listNotFound:
            return "Shopping list not found"
        case .uiError(let message):
            return "UI Error: \(message)"
        case .networkError(let message):
            return "Network Error: \(message)"
        case .serverError(let message):
            return "Server Error: \(message)"
        case .permissionDenied(let message):
            return "Permission Denied: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .dataEncodingError, .dataDecodingError, .dataSaveError:
            return "Please try again. If the problem persists, contact support."
        case .dataNotFound:
            return "The requested data could not be found. Please check your input and try again."
        case .invalidInput:
            return "Please check your input and try again."
        case .invalidQuantity:
            return "Please enter a quantity greater than 0."
        case .invalidListName:
            return "Please enter a valid list name."
        case .listAlreadyExists:
            return "Please choose a different name for your list."
        case .listNotFound:
            return "Please check the list name and try again."
        case .uiError:
            return "Please try again. If the problem persists, restart the app."
        case .networkError:
            return "Please check your internet connection and try again."
        case .serverError:
            return "The server is currently unavailable. Please try again later."
        case .permissionDenied:
            return "Please grant the necessary permissions in Settings."
        }
    }
}

// MARK: - Error Handling Protocol
protocol ErrorHandling {
    func handle(_ error: Error)
}

// MARK: - Error Alert View Modifier
struct ErrorAlert: ViewModifier {
    @Binding var error: AppError?
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .alert(
                error?.errorDescription ?? "Error",
                isPresented: $isPresented,
                actions: {
                    Button("OK") {
                        isPresented = false
                        error = nil
                    }
                },
                message: {
                    if let suggestion = error?.recoverySuggestion {
                        Text(suggestion)
                    }
                }
            )
    }
}

// MARK: - View Extension
extension View {
    func errorAlert(error: Binding<AppError?>, isPresented: Binding<Bool>) -> some View {
        modifier(ErrorAlert(error: error, isPresented: isPresented))
    }
} 