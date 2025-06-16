import Foundation

public enum SortOrder: String, CaseIterable, Identifiable {
    case nameAsc = "Name (A-Z)"
    case nameDesc = "Name (Z-A)"
    case dateAsc = "Date (Oldest)"
    case dateDesc = "Date (Newest)"
    case categoryAsc = "Category (A-Z)"
    case categoryDesc = "Category (Z-A)"
    
    public var id: String { rawValue }
    
    public var displayName: String { rawValue }
} 