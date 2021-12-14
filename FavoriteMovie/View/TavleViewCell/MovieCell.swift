import UIKit

protocol MovieCellDelegate: AnyObject {
    func removeCell(cell: UITableViewCell)
}

class MovieCell: UITableViewCell {
    
    // MARK: - Protperties
    
    private let presenter = MovieCellPresenter()
    weak var delegate: MovieCellDelegate?
    var movie: Movie!
    var isFavorite = false
    
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
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        presenter.inject(delegate: self)
        
        selectionStyle = .none

        self.addSubview(movieImageView)
        
        movieImageView.anchor(top: self.topAnchor, left: self.leadingAnchor, bottom: self.bottomAnchor, paddingTop: 8, paddingBottom: 8, width: 70)
        
        contentView.addSubview(favoriteButton)
        
        favoriteButton.anchor(top: movieImageView.topAnchor, right: self.trailingAnchor)
        favoriteButton.setDimensions(width: 24, height: 24)
        favoriteButton.addTarget(self, action: #selector(toggleFavoriteAttribute), for: .touchUpInside)
        
        self.addSubview(titleLabel)
        
        titleLabel.anchor(top: movieImageView.topAnchor, left: movieImageView.trailingAnchor, bottom: favoriteButton.bottomAnchor, right: favoriteButton.leadingAnchor, paddingLeft: 8)
        
        let stackView = UIStackView(arrangedSubviews: [directorLabel, actorLabel, ratingLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        
        self.addSubview(stackView)
        
        stackView.anchor(top: favoriteButton.bottomAnchor, left: movieImageView.trailingAnchor, bottom: movieImageView.bottomAnchor, right: self.trailingAnchor, paddingLeft: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors

    @objc private func toggleFavoriteAttribute() {
        isFavorite = !isFavorite
        changeFavoriteButtonImage()
        presenter.changeFavoriteAttribute(movie: movie, action: isFavorite ? .add : .remove)
    }
    
    // MARK: - Helper Functions
        
    public func configure(movie: Movie) {
        self.movie = movie
        movieImageView.image = movie.imageLink.mapImageLinkToUIImage()
        titleLabel.text = movie.title.removeHtmlBoldTagFromText()
        directorLabel.text = "감독: \(movie.directors.replaceArrangeChar())"
        actorLabel.text = "출연: \(movie.actors.replaceArrangeChar())"
        ratingLabel.text = "평점: \(movie.userRating)"
        changeFavoriteButtonImage()
    }
    
    private func changeFavoriteButtonImage() {
        if isFavorite {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
}

// MARK: - MovieCellPresenterDelegate

extension MovieCell: MovieCellPresenterDelegate {
    func setMovie(_ movie: Movie) {
        self.movie = movie
    }
    
    func deleteCell(isDeleted: Bool) {
        if isDeleted {
            delegate?.removeCell(cell: self)
        } else {
            isFavorite = !isFavorite
            changeFavoriteButtonImage()
        }
    }
}
