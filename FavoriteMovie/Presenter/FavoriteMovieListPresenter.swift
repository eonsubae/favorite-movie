import Foundation

protocol FavoriteMovieListPresenterDelegate: AnyObject {
    func renderFavoriteMovieList(favoriteMovies: [Movie])
}

class FavoriteMovieListPresenter {
    
    private let movieService = MovieService.shared

    weak var delegate: FavoriteMovieListPresenterDelegate?

    public func inject(delegate: FavoriteMovieListPresenterDelegate) {
        self.delegate = delegate
    }
    
    public func getFavoriteMovies() {
        movieService.fetchFavoriteMovieList { favoriteMovies in
            self.delegate?.renderFavoriteMovieList(favoriteMovies: favoriteMovies)
        }
    }
}
