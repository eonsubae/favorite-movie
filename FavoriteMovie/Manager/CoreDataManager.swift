import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
        
    init() {
        persistentContainer = NSPersistentContainer(name: "FavoriteMovie")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data Store failed to initialize \(error.localizedDescription)")
            }
        }
    }
    
    func findOneFavoriteMovie(movie: Movie) -> Movie? {
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "link = %@", movie.link)
        
        do {
            let favoriteMovie = try persistentContainer.viewContext.fetch(fetchRequest)
            return mapFavoriteToDefault(favoriteMovie[0])
        } catch {
            print("Failed to load favorite movies : \(error)")
            return nil
        }
    }
       
    func getFavoriteMovies() -> [Movie] {
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        
        do {
            let favoriteMovies = try persistentContainer.viewContext.fetch(fetchRequest)
            return mapFavoriteArrayToDefaultArray(favoriteMovies)
        } catch {
            print("Failed to load favorite movies : \(error)")
            return []
        }
    }
    
    func saveFavoriteMovie (movie: Movie) -> Movie? {
        let favoriteMovie = FavoriteMovie(context: persistentContainer.viewContext)
        favoriteMovie.title = movie.title
        favoriteMovie.link = movie.link
        favoriteMovie.imageLink = movie.imageLink
        favoriteMovie.subtitle = movie.subtitle
        favoriteMovie.pubDate = movie.pubDate
        favoriteMovie.directors = movie.directors
        favoriteMovie.actors = movie.actors
        favoriteMovie.userRating = movie.userRating
        
        do {
            try persistentContainer.viewContext.save()
            return mapFavoriteToDefault(favoriteMovie)
        } catch {
            print("Failed to save movie : \(error)")
            return nil
        }
    }
    
    func deleteFavoriteMovie(movie: Movie) -> Bool {
        let context = persistentContainer.viewContext
        
        do {
            let favoriteMovie = try context.existingObject(with: movie.objectID!)
            context.delete(favoriteMovie)
            try context.save()
            return true
        } catch {
            context.rollback()
            print("Failed to delete favorite movie : \(error)")
            return false
        }
    }
    
    private func mapFavoriteToDefault(_ favoriteMovie: FavoriteMovie) -> Movie {
        return Movie(objectID: favoriteMovie.objectID, title: favoriteMovie.title, link: favoriteMovie.link, imageLink: favoriteMovie.imageLink, subtitle: favoriteMovie.subtitle, pubDate: favoriteMovie.pubDate, directors: favoriteMovie.directors, actors: favoriteMovie.actors, userRating: favoriteMovie.userRating)
    }

    private func mapFavoriteArrayToDefaultArray(_ favoriteMovies: [FavoriteMovie]) -> [Movie] {
        return favoriteMovies.map { favoriteMovie in
            return mapFavoriteToDefault(favoriteMovie)
        }
    }
}
