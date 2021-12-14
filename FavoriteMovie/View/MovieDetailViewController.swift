import UIKit
import WebKit

protocol MovieDetailDelegate: AnyObject {
    func changeMovie(changedMovie: Movie)
}

class MovieDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let presenter = MovieDetailPresenter()
    weak var delegate: MovieDetailPresenterDelegate?
    var movie: Movie!
    var isFavorite = false
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.1)
        return view
    }()
    
    private let cellContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .defaultBgColor
        return view
    }()
    
    private let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private let directorLabel: UILabel = {
        let label = UILabel()
        label.text = "감독"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let actorLabel: UILabel = {
        let label = UILabel()
        label.text = "출연"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "평점"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    private let webViewContainer = UIView()
    private var webview: WKWebView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.inject(delegate: self)
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.checkIsFavorite(movie: movie)
        
        if movie.objectID != nil {
            isFavorite = true
        }
        
        changeFavoriteButtonImage()
        configureNavigationBar()
    }
    
    // MARK: - Selectors
    
    @objc private func toggleFavoriteAttribute() {
        isFavorite = !isFavorite
        changeFavoriteButtonImage()
        presenter.changeFavoriteAttribute(movie: movie, action: isFavorite ? .add : .remove)
    }
    
    // MARK: - Helper Functions
    
    private func configure() {
        view.backgroundColor = .defaultBgColor

        configureCell()
        configureWebView()
    }
    
    private func configureCell() {
        view.addSubview(containerView)
        
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.trailingAnchor)
        
        containerView.addSubview(cellContainerView)
        cellContainerView.anchor(top: containerView.topAnchor, left: containerView.leadingAnchor, right: containerView.trailingAnchor, paddingTop: 8, height: 100)
        
        cellContainerView.addSubview(movieImageView)
        movieImageView.image = movie.imageLink.mapImageLinkToUIImage()
        
        movieImageView.anchor(top: cellContainerView.topAnchor, left: cellContainerView.leadingAnchor, bottom: cellContainerView.bottomAnchor, paddingTop: 8, paddingLeft: 16, paddingBottom: 8, width: 70)
        
        cellContainerView.addSubview(favoriteButton)
        
        favoriteButton.anchor(top: cellContainerView.topAnchor, right: cellContainerView.trailingAnchor, paddingTop: 8, paddingRight: 16)
        favoriteButton.setDimensions(width: 24, height: 24)
        favoriteButton.addTarget(self, action: #selector(toggleFavoriteAttribute), for: .touchUpInside)
        
        cellContainerView.addSubview(titleLabel)
        
        titleLabel.text = movie.title.removeHtmlBoldTagFromText()
        titleLabel.anchor(top: movieImageView.topAnchor, left: movieImageView.trailingAnchor, bottom: favoriteButton.bottomAnchor, right: favoriteButton.leadingAnchor, paddingLeft: 8, paddingRight: 8)
        
        let stackView = UIStackView(arrangedSubviews: [directorLabel, actorLabel, ratingLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        
        cellContainerView.addSubview(stackView)
        
        stackView.anchor(top: favoriteButton.bottomAnchor, left: movieImageView.trailingAnchor, bottom: movieImageView.bottomAnchor, right: favoriteButton.leadingAnchor, paddingLeft: 8, paddingRight: 8)
        directorLabel.text = "감독: \(movie.directors.replaceArrangeChar())"
        actorLabel.text = "출연: \(movie.actors.replaceArrangeChar())"
        ratingLabel.text = "평점: \(movie.userRating)"
    }
    
    private func configureWebView() {
        containerView.addSubview(webViewContainer)

        webViewContainer.anchor(top: cellContainerView.bottomAnchor, left: containerView.leadingAnchor, bottom: containerView.bottomAnchor, right: containerView.trailingAnchor)
        
        webview = WKWebView(frame: webViewContainer.frame)
        webview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webViewContainer.addSubview(webview)
        
        guard let url = URL(string: movie.link) else { return }
        let urlRequest = URLRequest(url: url)
        webview.load(urlRequest)
    }
    
    private func configureNavigationBar() {
        let backImage = UIImage(systemName: "chevron.left")
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        navAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        navAppearance.shadowColor = .clear

        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .black.withAlphaComponent(0.7)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        navigationItem.title = movie?.title.removeHtmlBoldTagFromText()
    }
    
    private func changeFavoriteButtonImage() {
        if isFavorite {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    
    public func setMovie(movie: Movie) {
        self.movie = movie
    }
}

// MARK: - MovieDetailPresenterDelegate

extension MovieDetailViewController: MovieDetailPresenterDelegate {
    func setFavoriteMovie(_ movie: Movie) {
        self.movie = movie
    }
    
    func removeObjectID() {
        self.movie.objectID = nil
    }
}
