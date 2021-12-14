import Foundation

let NAVER_MOVIE_API_URL = "https://openapi.naver.com/v1/search/movie.json"
let NAVER_CLIENT_ID = "PRkEdJ0ecPvSB0ynRPap"
let NAVER_SECRET_KEY = "dbbkdW16SG"

struct MovieService {
    
    // MARK: - Properties

    static let shared = MovieService()
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Helper Functions

    func fetchMovieList(query: String, completion: @escaping([Movie]) -> Void) {
        var components = URLComponents(string: NAVER_MOVIE_API_URL)
        components?.queryItems = [URLQueryItem(name: "query", value: query)]
        guard let url = components?.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(NAVER_CLIENT_ID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.setValue(NAVER_SECRET_KEY, forHTTPHeaderField: "X-Naver-Client-Secret")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            do {
                let movieListResponse = try JSONDecoder().decode(MovieListResponse.self, from: data)
                completion(movieListResponse.items)
            }
            catch {
                print("An error occured : \(error)")
            }
        }.resume()
    }
    
    func fetchFavoriteMovieList(completion: @escaping([Movie]) -> Void) {
        let favoriteMovies = coreDataManager.getFavoriteMovies()
        completion(favoriteMovies)
    }
    
    func fetchOneFavoriteMovie(_ movie: Movie, completion: @escaping(Movie) -> Void) {
        guard let favoriteMovie = coreDataManager.findOneFavoriteMovie(movie: movie) else { return }
        completion(favoriteMovie)
    }
    
    func addFavoriteMovie(_ movie: Movie, completion: @escaping(Movie) -> Void) {
        guard let movie = coreDataManager.saveFavoriteMovie(movie: movie) else { return }
        completion(movie)
    }
    
    func removeFavoriteMovie(_ movie: Movie, completion: @escaping(Bool) -> Void) {
        let isDeleted = coreDataManager.deleteFavoriteMovie(movie: movie)
        completion(isDeleted)
    }
}
