import Foundation
import CoreLocation

struct LocationReminder: Codable {
    let id: UUID
    let listId: UUID
    let location: CLLocationCoordinate2D
    let radius: Double
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case listId
        case latitude
        case longitude
        case radius
        case message
    }
    
    init(id: UUID = UUID(), listId: UUID, location: CLLocationCoordinate2D, radius: Double, message: String) {
        self.id = id
        self.listId = listId
        self.location = location
        self.radius = radius
        self.message = message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        listId = try container.decode(UUID.self, forKey: .listId)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = try container.decode(Double.self, forKey: .radius)
        message = try container.decode(String.self, forKey: .message)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(listId, forKey: .listId)
        try container.encode(location.latitude, forKey: .latitude)
        try container.encode(location.longitude, forKey: .longitude)
        try container.encode(radius, forKey: .radius)
        try container.encode(message, forKey: .message)
    }
} 