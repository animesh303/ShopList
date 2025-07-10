import XCTest
@testable import ShopList

final class AppErrorTests: XCTestCase {
    
    func testAppErrorCreation() {
        // Test creating various error types
        let networkError = AppError.networkError("Connection failed")
        let invalidInputError = AppError.invalidInput("Invalid email format")
        let permissionError = AppError.permissionDenied("Location access required")
        let unknownError = AppError.unknown("Something went wrong")
        
        XCTAssertNotNil(networkError)
        XCTAssertNotNil(invalidInputError)
        XCTAssertNotNil(permissionError)
        XCTAssertNotNil(unknownError)
    }
    
    func testAppErrorLocalizedDescription() {
        // Test that all errors have localized descriptions
        let networkError = AppError.networkError("Connection failed")
        let invalidInputError = AppError.invalidInput("Invalid email format")
        let permissionError = AppError.permissionDenied("Location access required")
        let unknownError = AppError.unknown("Something went wrong")
        let dataError = AppError.dataEncodingError("JSON encoding failed")
        let validationError = AppError.invalidQuantity
        let listError = AppError.listAlreadyExists
        
        XCTAssertFalse(networkError.localizedDescription.isEmpty)
        XCTAssertFalse(invalidInputError.localizedDescription.isEmpty)
        XCTAssertFalse(permissionError.localizedDescription.isEmpty)
        XCTAssertFalse(unknownError.localizedDescription.isEmpty)
        XCTAssertFalse(dataError.localizedDescription.isEmpty)
        XCTAssertFalse(validationError.localizedDescription.isEmpty)
        XCTAssertFalse(listError.localizedDescription.isEmpty)
    }
    
    func testAppErrorErrorDescription() {
        let networkError = AppError.networkError("Connection failed")
        let invalidInputError = AppError.invalidInput("Invalid email format")
        let permissionError = AppError.permissionDenied("Location access required")
        let unknownError = AppError.unknown("Something went wrong")
        
        XCTAssertTrue(networkError.errorDescription?.contains("Network Error") == true)
        XCTAssertTrue(invalidInputError.errorDescription?.contains("Invalid input") == true)
        XCTAssertTrue(permissionError.errorDescription?.contains("Permission Denied") == true)
        XCTAssertTrue(unknownError.errorDescription?.contains("unexpected error") == true)
    }
    
    func testAppErrorRecoverySuggestion() {
        let networkError = AppError.networkError("Connection failed")
        let invalidInputError = AppError.invalidInput("Invalid email format")
        let permissionError = AppError.permissionDenied("Location access required")
        let unknownError = AppError.unknown("Something went wrong")
        let dataError = AppError.dataEncodingError("JSON encoding failed")
        let validationError = AppError.invalidQuantity
        let listError = AppError.listAlreadyExists
        
        XCTAssertNotNil(networkError.recoverySuggestion)
        XCTAssertNotNil(invalidInputError.recoverySuggestion)
        XCTAssertNotNil(permissionError.recoverySuggestion)
        XCTAssertNotNil(unknownError.recoverySuggestion)
        XCTAssertNotNil(dataError.recoverySuggestion)
        XCTAssertNotNil(validationError.recoverySuggestion)
        XCTAssertNotNil(listError.recoverySuggestion)
    }
    
    func testAppErrorEquality() {
        let error1 = AppError.networkError("Connection failed")
        let error2 = AppError.networkError("Connection failed")
        let error3 = AppError.networkError("Different error")
        let error4 = AppError.invalidInput("Invalid input")
        
        // Test equality with same associated values
        XCTAssertEqual(error1.errorDescription, error2.errorDescription)
        
        // Test inequality with different associated values
        XCTAssertNotEqual(error1.errorDescription, error3.errorDescription)
        
        // Test inequality with different error types
        XCTAssertNotEqual(error1.errorDescription, error4.errorDescription)
    }
    
    func testAppErrorTypes() {
        // Test data errors
        let dataEncodingError = AppError.dataEncodingError("JSON encoding failed")
        let dataDecodingError = AppError.dataDecodingError("JSON decoding failed")
        let dataNotFoundError = AppError.dataNotFound("User data not found")
        let dataSaveError = AppError.dataSaveError("Failed to save to disk")
        
        XCTAssertTrue(dataEncodingError.errorDescription?.contains("encode") == true)
        XCTAssertTrue(dataDecodingError.errorDescription?.contains("decode") == true)
        XCTAssertTrue(dataNotFoundError.errorDescription?.contains("not found") == true)
        XCTAssertTrue(dataSaveError.errorDescription?.contains("save") == true)
        
        // Test validation errors
        let invalidQuantityError = AppError.invalidQuantity
        let invalidListNameError = AppError.invalidListName
        let listAlreadyExistsError = AppError.listAlreadyExists
        let listNotFoundError = AppError.listNotFound
        
        XCTAssertTrue(invalidQuantityError.errorDescription?.contains("greater than 0") == true)
        XCTAssertTrue(invalidListNameError.errorDescription?.contains("empty") == true)
        XCTAssertTrue(listAlreadyExistsError.errorDescription?.contains("already exists") == true)
        XCTAssertTrue(listNotFoundError.errorDescription?.contains("not found") == true)
        
        // Test UI errors
        let uiError = AppError.uiError("View rendering failed")
        XCTAssertTrue(uiError.errorDescription?.contains("UI Error") == true)
        
        // Test server errors
        let serverError = AppError.serverError("Internal server error")
        XCTAssertTrue(serverError.errorDescription?.contains("Server Error") == true)
    }
    
    func testAppErrorUserFriendlyMessages() {
        // Test that error messages are user-friendly
        let networkError = AppError.networkError("Connection failed")
        let permissionError = AppError.permissionDenied("Location access required")
        let validationError = AppError.invalidQuantity
        let listError = AppError.listAlreadyExists
        
        let networkMessage = networkError.errorDescription ?? ""
        let permissionMessage = permissionError.errorDescription ?? ""
        let validationMessage = validationError.errorDescription ?? ""
        let listMessage = listError.errorDescription ?? ""
        
        XCTAssertTrue(networkMessage.contains("Network Error") || networkMessage.contains("connection") || networkMessage.contains("internet"))
        XCTAssertTrue(permissionMessage.contains("Permission Denied") || permissionMessage.contains("permission") || permissionMessage.contains("access"))
        XCTAssertTrue(validationMessage.contains("greater than 0") || validationMessage.contains("quantity"))
        XCTAssertTrue(listMessage.contains("already exists") || listMessage.contains("list"))
    }
    
    func testAppErrorRecoverySuggestions() {
        // Test that errors provide helpful recovery suggestions
        let networkError = AppError.networkError("Connection failed")
        let permissionError = AppError.permissionDenied("Location access required")
        let validationError = AppError.invalidQuantity
        let listError = AppError.listAlreadyExists
        
        let networkSuggestion = networkError.recoverySuggestion ?? ""
        let permissionSuggestion = permissionError.recoverySuggestion ?? ""
        let validationSuggestion = validationError.recoverySuggestion ?? ""
        let listSuggestion = listError.recoverySuggestion ?? ""
        
        // These should have meaningful suggestions that help users understand what to do
        XCTAssertFalse(networkSuggestion.isEmpty)
        XCTAssertFalse(permissionSuggestion.isEmpty)
        XCTAssertFalse(validationSuggestion.isEmpty)
        XCTAssertFalse(listSuggestion.isEmpty)
        
        // Test specific suggestions
        XCTAssertTrue(networkSuggestion.contains("internet") || networkSuggestion.contains("connection"))
        XCTAssertTrue(permissionSuggestion.contains("permission") || permissionSuggestion.contains("Settings"))
        XCTAssertTrue(validationSuggestion.contains("greater than 0"))
        XCTAssertTrue(listSuggestion.contains("different name"))
    }
    
    func testAppErrorAssociatedValues() {
        // Test that associated values are properly handled
        let customMessage = "Custom error message"
        let networkError = AppError.networkError(customMessage)
        let invalidInputError = AppError.invalidInput(customMessage)
        let permissionError = AppError.permissionDenied(customMessage)
        let unknownError = AppError.unknown(customMessage)
        
        XCTAssertTrue(networkError.errorDescription?.contains(customMessage) == true)
        XCTAssertTrue(invalidInputError.errorDescription?.contains(customMessage) == true)
        XCTAssertTrue(permissionError.errorDescription?.contains(customMessage) == true)
        XCTAssertTrue(unknownError.errorDescription?.contains(customMessage) == true)
    }
} 