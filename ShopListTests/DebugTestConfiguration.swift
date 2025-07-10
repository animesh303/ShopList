import Foundation
import XCTest

/// Debug configuration for tests to help identify crash causes
struct DebugTestConfiguration {
    
    /// Enable detailed logging for debugging crashes
    static let enableDetailedLogging = true
    
    /// Enable crash detection and reporting
    static let enableCrashDetection = true
    
    /// Maximum timeout for async operations
    static let maxAsyncTimeout: TimeInterval = 10.0
    
    /// Enable SwiftData validation
    static let enableSwiftDataValidation = true
    
    /// Enable memory leak detection
    static let enableMemoryLeakDetection = true
}

/// Debug logger for tests
class TestLogger {
    static func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if DebugTestConfiguration.enableDetailedLogging {
            let fileName = URL(fileURLWithPath: file).lastPathComponent
            print("[TEST DEBUG] \(fileName):\(line) - \(function): \(message)")
        }
    }
    
    static func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        var errorMessage = "[TEST ERROR] \(fileName):\(line) - \(function): \(message)"
        if let error = error {
            errorMessage += " - Error: \(error.localizedDescription)"
        }
        print(errorMessage)
    }
}

/// Crash detection helper
class CrashDetector {
    private static var crashCount = 0
    private static let maxCrashes = 10
    
    static func detectCrash() {
        crashCount += 1
        TestLogger.error("Potential crash detected (count: \(crashCount))")
        
        if crashCount >= maxCrashes {
            TestLogger.error("Too many potential crashes detected. Stopping tests.")
            // You could add additional crash reporting here
        }
    }
    
    static func reset() {
        crashCount = 0
    }
}

/// Memory leak detection helper
class MemoryLeakDetector {
    private static var weakReferences: [String: WeakReference] = [:]
    
    static func trackObject<T: AnyObject>(_ object: T, name: String) {
        if DebugTestConfiguration.enableMemoryLeakDetection {
            weakReferences[name] = WeakReference(object)
        }
    }
    
    static func checkForLeaks() {
        if DebugTestConfiguration.enableMemoryLeakDetection {
            for (name, weakRef) in weakReferences {
                if weakRef.object == nil {
                    TestLogger.log("Object '\(name)' was properly deallocated")
                } else {
                    TestLogger.error("Potential memory leak detected for object '\(name)'")
                }
            }
            weakReferences.removeAll()
        }
    }
}

/// Weak reference wrapper for memory leak detection
class WeakReference {
    weak var object: AnyObject?
    
    init(_ object: AnyObject) {
        self.object = object
    }
} 