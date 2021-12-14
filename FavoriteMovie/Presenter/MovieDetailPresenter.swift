import Foundation

protocol MovieDetailPresenterDelegate: AnyObject {
    func setFavoriteMovie(_ movie: Movie)
    func removeObjectID()
}

class MovieDetailPresenter {
    
    private let movieService = MovieService.shared
    
    weak var delegate: MovieDetailPresenterDelegate?
    
    public func inject(delegate: MovieDetailPresenterDelegate) {
        self.delegate = delegate
    }
    
    public func checkIsFavorite(movie: Movie) {
        movieService.fetchOneFavoriteMovie(movie) { favoriteMovie in
            self.delegate?.setFavoriteMovie(favoriteMovie)
        }
    }
    
    public func changeFavoriteAttribute(movie: Movie, action: FavoriteAction) {
        switch action {
        case .add:
            movieService.addFavoriteMovie(movie) { favoriteMovie in
                self.delegate?.setFavoriteMovie(favoriteMovie)
            }
        case .remove:
            movieService.removeFavoriteMovie(movie) { isDeleted in
                self.delegate?.removeObjectID()
            }
        }
    }
}
