import XCTest

final class ShoppingListUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testCreateNewList() throws {
        // Tap the add button
        app.navigationBars.buttons["plus"].tap()
        
        // Enter list name
        let textField = app.textFields["List Name"]
        textField.tap()
        textField.typeText("Test Shopping List")
        
        // Tap Add button
        app.navigationBars.buttons["Add"].tap()
        
        // Verify the list was created
        XCTAssertTrue(app.staticTexts["Test Shopping List"].exists)
    }
    
    func testAddItemToList() throws {
        // Create a new list first
        app.navigationBars.buttons["plus"].tap()
        let textField = app.textFields["List Name"]
        textField.tap()
        textField.typeText("Test List")
        app.navigationBars.buttons["Add"].tap()
        
        // Open the list
        app.staticTexts["Test List"].tap()
        
        // Add new item
        app.navigationBars.buttons["plus"].tap()
        
        // Fill in item details
        let nameTextField = app.textFields["Item Name"]
        nameTextField.tap()
        nameTextField.typeText("Milk")
        
        // Select category
        app.pickers["Category"].tap()
        app.buttons["Groceries"].tap()
        
        // Add the item
        app.navigationBars.buttons["Add"].tap()
        
        // Verify the item was added
        XCTAssertTrue(app.staticTexts["Milk"].exists)
    }
    
    func testMarkItemAsCompleted() throws {
        // Create a list with an item
        app.navigationBars.buttons["plus"].tap()
        let textField = app.textFields["List Name"]
        textField.tap()
        textField.typeText("Test List")
        app.navigationBars.buttons["Add"].tap()
        
        app.staticTexts["Test List"].tap()
        
        app.navigationBars.buttons["plus"].tap()
        let nameTextField = app.textFields["Item Name"]
        nameTextField.tap()
        nameTextField.typeText("Bread")
        app.navigationBars.buttons["Add"].tap()
        
        // Mark item as completed
        app.buttons["circle"].tap()
        
        // Verify the item is marked as completed
        XCTAssertTrue(app.buttons["checkmark.circle.fill"].exists)
    }
    
    func testDeleteList() throws {
        // Create a new list
        app.navigationBars.buttons["plus"].tap()
        let textField = app.textFields["List Name"]
        textField.tap()
        textField.typeText("List to Delete")
        app.navigationBars.buttons["Add"].tap()
        
        // Delete the list
        let list = app.staticTexts["List to Delete"]
        list.swipeLeft()
        app.buttons["Delete"].tap()
        
        // Verify the list was deleted
        XCTAssertFalse(app.staticTexts["List to Delete"].exists)
    }
    
    func testAddItemWithNotes() throws {
        // Create a new list
        app.navigationBars.buttons["plus"].tap()
        let textField = app.textFields["List Name"]
        textField.tap()
        textField.typeText("Test List")
        app.navigationBars.buttons["Add"].tap()
        
        // Open the list
        app.staticTexts["Test List"].tap()
        
        // Add new item with notes
        app.navigationBars.buttons["plus"].tap()
        
        let nameTextField = app.textFields["Item Name"]
        nameTextField.tap()
        nameTextField.typeText("Eggs")
        
        let notesTextField = app.textFields["Notes"]
        notesTextField.tap()
        notesTextField.typeText("Get free-range eggs")
        
        app.navigationBars.buttons["Add"].tap()
        
        // Verify the item and notes were added
        XCTAssertTrue(app.staticTexts["Eggs"].exists)
        XCTAssertTrue(app.staticTexts["Get free-range eggs"].exists)
    }
} 