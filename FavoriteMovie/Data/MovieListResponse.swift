import Foundation

struct MovieListResponse: Codable {
    let lastBuildDate: String
    let total: Int
    let start: Int
    let display: Int
    let items: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case lastBuildDate = "lastBuildDate"
        case total = "total"
        case start = "start"
        case display = "display"
        case items = "items"
    }
}
