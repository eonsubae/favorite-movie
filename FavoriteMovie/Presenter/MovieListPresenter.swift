import Foundation

protocol MovieListPresenterDelegate: AnyObject {
    func renderMovieList(movies: [Movie])
}

class MovieListPresenter {
    
    private let movieService = MovieService.shared
    
    weak var delegate: MovieListPresenterDelegate?
    
    public func inject(delegate: MovieListPresenterDelegate) {
        self.delegate = delegate
    }
    
    public func getMovies(searchWord: String) {
        movieService.fetchMovieList(query: searchWord) { movies in
            self.movieService.fetchFavoriteMovieList { favoriteMovies in
                if movies.count == 0 {
                    self.delegate?.renderMovieList(movies: [])
                }
                
                if favoriteMovies.count == 0 {
                    self.delegate?.renderMovieList(movies: movies)
                } else {
                    let filteredMovieList = self.filterFavoriteMovie(defaultMovies: movies, favoriteMovies: favoriteMovies)
                    self.delegate?.renderMovieList(movies: filteredMovieList)
                }
            }
        }
    }
    
    private func filterFavoriteMovie(defaultMovies: [Movie], favoriteMovies: [Movie]) -> [Movie] {
        return defaultMovies.map { dMovie in
            var movie = dMovie
            
            _ = favoriteMovies.allSatisfy { fMovie in
                if dMovie.link == fMovie.link {
                    movie = fMovie
                    return false
                } else {
                    return true
                }
            }
            
            return movie
        }
    }
}
