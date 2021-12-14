import Foundation
import CoreData

struct Movie: Codable {
    var objectID: NSManagedObjectID?
    let title: String
    let link: String
    let imageLink: String
    let subtitle: String
    let pubDate: String
    let directors: String
    let actors: String
    let userRating: String
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case link = "link"
        case imageLink = "image"
        case subtitle = "subtitle"
        case pubDate = "pubDate"
        case directors = "director"
        case actors = "actor"
        case userRating = "userRating"
    }
}
