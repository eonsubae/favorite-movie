import UIKit

class FavoriteMovieListViewController: UIViewController {

    // MARK: - Properties

    private let presenter = FavoriteMovieListPresenter()
    private var favoriteMovies: [Movie] = []

    private let tableView = UITableView()
    private let emptyInfoView = UIView()

    private let emptyInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "목록이 비었습니다."
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        
        presenter.inject(delegate: self)
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.getFavoriteMovies()
        configureNavigationBar()
    }
    
    // MARK: - Helper Functions
    
    private func configure() {
        view.backgroundColor = .defaultBgColor
        
        configureTableView()
        configureEmptyInfoView()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.trailingAnchor, paddingTop: 8, paddingLeft: 16, paddingRight: 16)
        tableView.rowHeight = 100
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func configureEmptyInfoView() {
        view.addSubview(emptyInfoView)
        
        emptyInfoView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.trailingAnchor, paddingLeft: 16, paddingRight: 16)
        
        emptyInfoView.addSubview(emptyInfoLabel)
        
        emptyInfoLabel.anchor(left: emptyInfoView.leadingAnchor, right: emptyInfoView.trailingAnchor)
        emptyInfoLabel.centerY(inView: emptyInfoView, constant: -60)
    }
    
    private func configureNavigationBar() {
        let backImage = UIImage(systemName: "xmark")
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        navAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        navAppearance.shadowColor = .clear

        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .black.withAlphaComponent(0.7)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        navigationItem.title = "즐겨찾기 목록"
    }
    
    private func updateList() {
        if favoriteMovies.count == 0 {
            tableView.isHidden = true
            emptyInfoView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyInfoView.isHidden = true
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate

extension FavoriteMovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailVC = MovieDetailViewController()
        movieDetailVC.setMovie(movie: favoriteMovies[indexPath.row])
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension FavoriteMovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.delegate = self
        cell.isFavorite = true
        cell.configure(movie: favoriteMovies[indexPath.row])
        return cell
    }
}

// MARK: - FavoriteMovieListPresenterDelegate

extension FavoriteMovieListViewController: FavoriteMovieListPresenterDelegate {
    func renderFavoriteMovieList(favoriteMovies: [Movie]) {
        self.favoriteMovies = favoriteMovies
        
        DispatchQueue.main.async {
            self.updateList()
        }
    }
}

// MARK: - MovieCellDelegate

extension FavoriteMovieListViewController: MovieCellDelegate {    
    func removeCell(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        favoriteMovies.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        updateList()
    }
}
