import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    private let indicatorView = UIActivityIndicatorView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorView.frame = contentView.frame
    }
    
    func cellInit(image: UIImage) {
        indicatorView.removeFromSuperview()
        photoImageView.image = image
        indicatorView.stopAnimating()
    }
    
    func initEmptyCell() {
        contentView.addSubview(indicatorView)
        indicatorView.startAnimating()
    }
}
