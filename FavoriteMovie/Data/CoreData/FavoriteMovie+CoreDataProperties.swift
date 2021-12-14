import Foundation
import CoreData


extension FavoriteMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteMovie> {
        return NSFetchRequest<FavoriteMovie>(entityName: "FavoriteMovie")
    }

    @NSManaged public var actors: String
    @NSManaged public var directors: String
    @NSManaged public var imageLink: String
    @NSManaged public var link: String
    @NSManaged public var pubDate: String
    @NSManaged public var subtitle: String
    @NSManaged public var title: String
    @NSManaged public var userRating: String

}

extension FavoriteMovie : Identifiable {

}
