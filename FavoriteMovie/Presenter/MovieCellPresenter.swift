import Foundation

enum FavoriteAction {
    case add
    case remove
}

protocol MovieCellPresenterDelegate: AnyObject {
    func setMovie(_ movie: Movie)
    func deleteCell(isDeleted: Bool)
}

class MovieCellPresenter {
    
    private let movieService = MovieService.shared
    
    weak var delegate: MovieCellPresenterDelegate?
    
    public func inject(delegate: MovieCellPresenterDelegate) {
        self.delegate = delegate
    }
    
    public func changeFavoriteAttribute(movie: Movie, action: FavoriteAction) {
        switch action {
        case .add:
            movieService.addFavoriteMovie(movie) { updatedMovie in
                self.delegate?.setMovie(updatedMovie)
            }
        case .remove:
            movieService.removeFavoriteMovie(movie) { isDeleted in
                self.delegate?.deleteCell(isDeleted: isDeleted)
            }
        }
    }
}
