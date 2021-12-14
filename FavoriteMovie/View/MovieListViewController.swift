import UIKit

class MovieListViewController: UIViewController {
    
    // MARK: Properties

    private let presenter = MovieListPresenter()
    private var movies: [Movie] = []
    private var searchTimer: Timer?

    private let headerContainerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "네이버 영화 검색"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor.copy(alpha: 0.3)
        button.setTitle("즐겨찾기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        let leftImage = UIImage(systemName: "star.fill")
        button.setImage(leftImage, for: .normal)
        button.contentHorizontalAlignment = .center
        button.tintColor = .systemYellow
        return button
    }()
    
    private let movieSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchBar.searchBarStyle = .minimal
        searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        searchBar.searchTextField.layer.borderWidth = 1.0
        searchBar.searchTextField.layer.borderColor = UIColor.lightGray.cgColor.copy(alpha: 0.3)
        searchBar.searchTextField.layer.cornerRadius = 5
        return searchBar
    }()
    
    private let tableView = UITableView()
    private let emptyInfoView = UIView()
    
    private let emptyInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "검색결과가 없습니다.\n검색어를 입력해주세요."
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        movieSearchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        
        presenter.inject(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        syncData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        headerContainerView.addBottomLine(height: 0.3, color: UIColor.lightGray.cgColor)
    }
    
    // MARK: - Selectors
    
    @objc private func presentFavoriteList() {
        let favoriteListVC = FavoriteMovieListViewController()
        navigationController?.pushViewController(favoriteListVC, animated: true)
    }
    
    // MARK: - Helper Functions
    
    private func configure() {
        view.backgroundColor = .defaultBgColor
        
        configureHeader()
        configureSearchBar()
        configureTableView()
        configureEmptyInfoView()
    }
    
    private func configureHeader() {
        view.addSubview(headerContainerView)

        headerContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leadingAnchor, right: view.trailingAnchor, height: 80)
        
        headerContainerView.addSubview(titleLabel)
        
        titleLabel.anchor(left: headerContainerView.leadingAnchor, paddingLeft: 16)
        titleLabel.centerY(inView: headerContainerView)
        titleLabel.setDimensions(width: 160, height: 40)
        
        headerContainerView.addSubview(favoriteButton)
        
        favoriteButton.anchor(right: headerContainerView.trailingAnchor, paddingRight: 16)
        favoriteButton.centerY(inView: titleLabel)
        favoriteButton.setDimensions(width: 80, height: 40)
        favoriteButton.addTarget(self, action: #selector(presentFavoriteList), for: .touchUpInside)
    }

    private func configureSearchBar() {
        view.addSubview(movieSearchBar)
        
        movieSearchBar.anchor(top: headerContainerView.bottomAnchor, left: view.leadingAnchor, right: view.trailingAnchor, paddingLeft: 8, paddingRight: 8, height: 40)
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        tableView.anchor(top: movieSearchBar.bottomAnchor, left: view.leadingAnchor, bottom: view.bottomAnchor, right: view.trailingAnchor, paddingLeft: 16, paddingRight: 16)
        tableView.rowHeight = 100
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.isHidden = true
    }
    
    private func configureEmptyInfoView() {
        view.addSubview(emptyInfoView)
        
        emptyInfoView.anchor(top: movieSearchBar.bottomAnchor, left: view.leadingAnchor, bottom: view.bottomAnchor, right: view.trailingAnchor, paddingLeft: 16, paddingRight: 16)
        
        emptyInfoView.addSubview(emptyInfoLabel)
        
        emptyInfoLabel.anchor(left: emptyInfoView.leadingAnchor, right: emptyInfoView.trailingAnchor)
        emptyInfoLabel.centerY(inView: emptyInfoView, constant: -60)
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func syncData() {
        if let searchText = movieSearchBar.text, searchText != "" {
            presenter.getMovies(searchWord: searchText)
        }
    }
    
    private func updateList() {
        if movies.count == 0 {
            tableView.isHidden = true
            emptyInfoView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyInfoView.isHidden = true
            tableView.reloadData()
        }
    }
}

// MARK: - UISearchBarDelegate

extension MovieListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { [weak self] (timer) in
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                if searchText.count == 0 {
                    self?.movies = []
                    DispatchQueue.main.async {
                        self?.updateList()
                    }
                } else {
                    self?.presenter.getMovies(searchWord: searchText)
                }
            }
        })
    }
}

// MARK: - UITableViewDelegate

extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailVC = MovieDetailViewController()
        movieDetailVC.setMovie(movie: movies[indexPath.row])
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.isFavorite = false
        
        if movies[indexPath.row].objectID != nil {
            cell.isFavorite = true
        }
        
        cell.configure(movie: movies[indexPath.row])
        
        return cell
    }
}

// MARK: - MovieListPresenterDelegate

extension MovieListViewController: MovieListPresenterDelegate {
    func renderMovieList(movies: [Movie]) {
        self.movies = movies
        
        DispatchQueue.main.async {
            self.updateList()
        }
    }
}
